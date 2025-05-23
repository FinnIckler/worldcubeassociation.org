import React, {
  createContext, useCallback, useContext, useEffect, useMemo, useState,
} from 'react';
import { useQuery } from '@tanstack/react-query';
import { useDispatch } from '../../../lib/providers/StoreProvider';
import { getRegistrationByUser, getSingleRegistration } from '../api/registration/get/get_registrations';
import { showMessage } from '../Register/RegistrationMessage';
import pollRegistrations from '../api/registration/get/poll_registrations';

const REFETCH_INTERVAL = 3000;

const RegistrationContext = createContext();

const getRegistrationFromParams = ({
  competitionId,
  userId,
  registrationId = null,
}) => {
  if (registrationId) {
    return getSingleRegistration(registrationId);
  }

  return getRegistrationByUser(userId, competitionId);
};

export default function RegistrationProvider({
  competitionInfo,
  userInfo,
  registrationId,
  isProcessing,
  children,
}) {
  const dispatch = useDispatch();

  const [isPolling, setIsPolling] = useState(isProcessing);
  const [pollCounter, setPollCounter] = useState(0);

  const startPolling = useCallback(() => {
    setIsPolling(true);
  }, [setIsPolling]);

  const stopPolling = useCallback(() => {
    setIsPolling(false);
  }, [setIsPolling]);

  const { data: pollingData, status: pollingStatus } = useQuery({
    queryKey: ['registration-status-polling', userInfo.id, competitionInfo.id],
    queryFn: async () => pollRegistrations(userInfo.id, competitionInfo.id),
    refetchInterval: REFETCH_INTERVAL,
    onSuccess: () => {
      setPollCounter((prevCounter) => prevCounter + 1);
    },
    enabled: isPolling,
  });

  useEffect(() => {
    if (pollingData && !pollingData.processing) {
      stopPolling();
    }
  }, [pollingData, stopPolling]);

  const {
    data: registration,
    isFetching,
    refetch: refetchRegistration,
  } = useQuery({
    queryKey: ['registration', competitionInfo.id, userInfo.id, registrationId],
    queryFn: () => getRegistrationFromParams({
      competitionId: competitionInfo.id,
      userId: userInfo.id,
      registrationId,
    }),
    onError: (error) => {
      dispatch(
        showMessage(
          `competitions.registration_v2.errors.${error?.response?.data?.json?.error || 'unknown'}`,
          'negative',
        ),
      );
    },
  });

  const isRegistered = registration && registration.competing.registration_status !== 'cancelled';
  const isAccepted = isRegistered && registration.competing.registration_status === 'accepted';
  const isRejected = isRegistered && registration.competing.registration_status === 'rejected';
  const hasPaid = registration?.payment?.has_paid;
  const isPending = isRegistered && registration.competing.registration_status === 'pending';
  const isWaitingList = isRegistered && registration.competing.registration_status === 'waiting_list';

  const value = useMemo(() => ({
    isRegistered,
    isAccepted,
    isRejected,
    hasPaid,
    isPending,
    isWaitingList,
    registration,
    refetchRegistration,
    isFetching,
    pollCounter,
    isPolling,
    startPolling,
    isProcessing: pollingStatus !== 'success' || pollingData.processing,
    queueCount: pollingData?.queue_count,
  }), [
    pollingStatus,
    hasPaid,
    isAccepted,
    isFetching,
    isRegistered,
    isRejected,
    isPending,
    isWaitingList,
    isPolling,
    refetchRegistration,
    registration,
    pollCounter,
    pollingData,
    startPolling,
  ]);

  return (
    <RegistrationContext.Provider value={value}>
      {children}
    </RegistrationContext.Provider>
  );
}

export const useRegistration = () => {
  const context = useContext(RegistrationContext);
  if (!context) {
    throw new Error('useRegistration must be used within a RegistrationProvider');
  }
  return context;
};
