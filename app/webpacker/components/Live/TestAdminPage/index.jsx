import React, { useState, useEffect, useCallback } from 'react';
import {
  Form, Grid, Button, Message, Header, Segment,
} from 'semantic-ui-react';
import { createConsumer } from '@rails/actioncable';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { fetchJsonOrError } from '../../../lib/requests/fetchWithAuthenticityToken';
import { events } from '../../../lib/wca-data.js.erb';
import WCAQueryClientProvider from '../../../lib/providers/WCAQueryClientProvider';
import ResultsTable from '../components/ResultsTable';
import { liveUrls } from '../../../lib/requests/routes.js.erb';
import AttemptResultField from '../../EditResult/WCALive/AttemptResultField/AttemptResultField';
import getRoundResults from '../api/getRoundResults';
import submitRoundResults from '../api/submitRoundResults';
import updateRoundResults from '../api/updateRoundResults';

export default function Wrapper({
  roundId, eventId, competitionId, competitors,
}) {
  return (
    <WCAQueryClientProvider>
      <AddResults
        competitionId={competitionId}
        roundId={roundId}
        eventId={eventId}
        competitors={competitors}
      />
    </WCAQueryClientProvider>
  );
}

function AddResults({
  competitionId, roundId, eventId, competitors,
}) {
  const [registrationId, setRegistrationId] = useState('');
  const [attempts, setAttempts] = useState([0, 0, 0, 0, 0]);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const queryClient = useQueryClient();

  const { data: results, isLoading } = useQuery({
    queryKey: [roundId, 'results'],
    queryFn: () => getRoundResults(roundId, competitionId),
  });

  const handleRegistrationIdChange = useCallback((_, { value }) => {
    setRegistrationId(value);
    const alreadyEnteredResults = results.find((r) => r.registration_id === value);
    if (alreadyEnteredResults) {
      setAttempts(alreadyEnteredResults.attempts);
    } else {
      setAttempts([0, 0, 0, 0, 0]);
    }
  }, [results]);

  const {
    mutate: mutateSubmit, isPending: isPendingSubmit,
  } = useMutation({
    mutationFn: submitRoundResults,
    onSuccess: () => {
      setSuccess('Results added successfully!');
      setRegistrationId('');
      setAttempts([0, 0, 0, 0, 0]);
      setError('');

      setTimeout(() => setSuccess(''), 3000);
    },
    onError: () => {
      setError('Failed to submit results. Please try again.');
    },
  });

  const {
    mutate: mutateUpdate, isPending: isPendingUpdate,
  } = useMutation({
    mutationFn: updateRoundResults,
    onSuccess: () => {
      setSuccess('Results added successfully!');
      setRegistrationId('');
      setAttempts([0, 0, 0, 0, 0]);
      setError('');

      setTimeout(() => setSuccess(''), 3000);
    },
    onError: () => {
      setError('Failed to submit results. Please try again.');
    },
  });

  useEffect(() => {
    const cable = createConsumer();

    const subscription = cable.subscriptions.create(
      { channel: 'LiveResultsChannel', round_id: roundId },
      {
        received: (data) => {
          queryClient.setQueryData([roundId, 'results'], (oldData) => [...oldData, data]);
        },
      },
    );

    return () => {
      subscription.unsubscribe();
    };
  }, [roundId, queryClient, eventId]);

  const handleAttemptChange = (index, value) => {
    const newAttempts = [...attempts];
    newAttempts[index] = value;
    setAttempts(newAttempts);
  };

  const handleSubmit = async () => {
    if (!registrationId) {
      setError('Please enter a user ID');
      return;
    }

    if (results.find((r) => r.registration_id === registrationId)) {
      mutateUpdate({
        roundId, registrationId, competitionId, attempts,
      });
    } else {
      mutateSubmit({
        roundId, registrationId, competitionId, attempts,
      });
    }
  };

  return (
    <Segment loading={isLoading || isPendingSubmit || isPendingUpdate}>
      <Header>
        {competitionId}
        :
        {' '}
        {events.byId[eventId].name}
      </Header>
      <Grid>
        <Grid.Column width={4}>
          <Form error={!!error} success={!!success}>
            <Header>
              Add New Result
            </Header>

            {error && <Message error content={error} />}
            {success && <Message success content={success} />}

            <Form.Select
              label="Competitor"
              placeholder="Competitor"
              value={registrationId}
              search={(inputs, value) => inputs.filter((d, i) => d.text.toLowerCase().includes(value.toLowerCase()) || parseInt(value, 10) === i)}
              onChange={handleRegistrationIdChange}
              options={competitors.toSorted((a, b) => a.id - b.id).map((p, i) => ({
                key: p.id,
                value: p.id,
                text: `${p.user.name} (${i + 1})`,
              }))}
            />

            {attempts.map((attempt, index) => (
              <AttemptResultField
                eventId={eventId}
                key={index}
                label={`Attempt ${index + 1}`}
                placeholder="Time in milliseconds or DNF"
                value={attempt}
                onChange={(value) => handleAttemptChange(index, value)}
              />
            ))}

            <Button primary onClick={handleSubmit}>Submit Results</Button>
          </Form>
        </Grid.Column>

        <Grid.Column width={12}>
          <Header>Live Results</Header>
          <ResultsTable results={results ?? []} eventId={eventId} competitors={competitors} competitionId={competitionId} />
        </Grid.Column>
      </Grid>
    </Segment>
  );
}
