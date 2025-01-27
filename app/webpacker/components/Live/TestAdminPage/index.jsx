import React, { useState, useEffect } from 'react';
import {
  Form, Grid, Button, Message, Header, Segment,
} from 'semantic-ui-react';
import { createConsumer } from '@rails/actioncable';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { fetchJsonOrError } from '../../../lib/requests/fetchWithAuthenticityToken';
import { events } from '../../../lib/wca-data.js.erb';
import WCAQueryClientProvider from '../../../lib/providers/WCAQueryClientProvider';
import ResultsTable from '../components/ResultsTable';

export default function Wrapper({ competitionId, roundId, eventId }) {
  return (
    <WCAQueryClientProvider>
      <AddResults competitionId={competitionId} roundId={roundId} eventId={eventId} />
    </WCAQueryClientProvider>
  );
}

async function getRoundResults(roundId, competitionId) {
  const { data } = await fetchJsonOrError(`/api/competitions/${competitionId}/rounds/${roundId}`);
  return data;
}

async function submitRoundResults({
  roundId, competitionId, userId, attempts,
}) {
  const { data } = await fetchJsonOrError(`/api/competitions/${competitionId}/rounds/${roundId}`, {
    headers: {
      'Content-Type': 'application/json',
    },
    method: 'POST',
    body: JSON.stringify({
      user_id: userId,
      round_id: roundId,
      attempts,
    }),
  });
  return data;
}

function AddResults({ competitionId, roundId, eventId }) {
  const [userId, setUserId] = useState('');
  const [attempts, setAttempts] = useState(['', '', '', '', '']);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const queryClient = useQueryClient();

  const { data: results, isLoading } = useQuery({
    queryKey: `${roundId}-results`,
    queryFn: () => getRoundResults(roundId, competitionId),
  });

  const {
    mutate, isPending,
  } = useMutation({
    mutationFn: submitRoundResults,
    onSuccess: () => {
      setSuccess('Results added successfully!');
      setUserId('');
      setAttempts(['', '', '', '', '']);
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
          queryClient.setQueryData(`${roundId}-results`, (oldData) => [...oldData, data]);
        },
      },
    );

    return () => {
      subscription.unsubscribe();
    };
  }, [roundId, queryClient, eventId]);

  const handleAttemptChange = (index, value) => {
    const newAttempts = [...attempts];
    newAttempts[index] = value.toLowerCase() === 'dnf' ? -1 : parseFloat(value);
    setAttempts(newAttempts);
  };

  const handleSubmit = async () => {
    if (!userId) {
      setError('Please enter a user ID');
      return;
    }

    mutate({
      roundId, userId, competitionId, attempts,
    });
  };

  return (
    <Segment loading={isLoading || isPending}>
      <Header>
        {competitionId}
        :
        {' '}
        {events.byId[eventId].name}
      </Header>
      <Grid>
        <Grid.Column width={8}>
          <Form error={!!error} success={!!success}>
            <Header>
              Add New Result
            </Header>

            {error && <Message error content={error} />}
            {success && <Message success content={success} />}

            <Form.Input
              label="User ID"
              placeholder="Enter user ID"
              value={userId}
              onChange={(e) => setUserId(e.target.value)}
            />

            {attempts.map((attempt, index) => (
              <Form.Input
                key={index}
                label={`Attempt ${index + 1}`}
                placeholder="Time in milliseconds or DNF"
                value={attempt === 'DNF' ? 'DNF' : attempt}
                onChange={(e) => handleAttemptChange(index, e.target.value)}
              />
            ))}

            <Button primary onClick={handleSubmit}>Submit Results</Button>
          </Form>
        </Grid.Column>

        <Grid.Column width={8}>
          <Header>Live Results</Header>
          <ResultsTable results={results ?? []} eventId={eventId} />
        </Grid.Column>
      </Grid>
    </Segment>
  );
}
