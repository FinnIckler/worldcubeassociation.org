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

export default function Wrapper({
  roundId, eventId, competitionId, competitors,
}) {
  return (
    <WCAQueryClientProvider>
      <AddResults competitionId={competitionId} roundId={roundId} eventId={eventId} competitors={competitors} />
    </WCAQueryClientProvider>
  );
}

async function getRoundResults(roundId, competitionId) {
  const { data } = await fetchJsonOrError(`/api/competitions/${competitionId}/rounds/${roundId}`);
  return data;
}

async function submitRoundResults({
  roundId, competitionId, registrationId, attempts,
}) {
  const { data } = await fetchJsonOrError(`/api/competitions/${competitionId}/rounds/${roundId}`, {
    headers: {
      'Content-Type': 'application/json',
    },
    method: 'POST',
    body: JSON.stringify({
      registration_id: registrationId,
      round_id: roundId,
      attempts,
    }),
  });
  return data;
}

function AddResults({
  competitionId, roundId, eventId, competitors,
}) {
  const [registrationId, setRegistrationId] = useState('');
  const [attempts, setAttempts] = useState(['', '', '', '', '']);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const queryClient = useQueryClient();

  const { data: results, isLoading } = useQuery({
    queryKey: [roundId, 'results'],
    queryFn: () => getRoundResults(roundId, competitionId),
  });

  useEffect(() => {
    if (registrationId) {
      const alreadyEnteredResults = results.find((r) => r.registration_id === registrationId);
      if (alreadyEnteredResults) {
        setAttempts(alreadyEnteredResults.attempts);
      }
    }
  }, [registrationId, results]);

  const {
    mutate, isPending,
  } = useMutation({
    mutationFn: submitRoundResults,
    onSuccess: () => {
      setSuccess('Results added successfully!');
      setRegistrationId('');
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
    newAttempts[index] = value.toLowerCase() === 'dnf' ? -1 : parseFloat(value);
    setAttempts(newAttempts);
  };

  const handleSubmit = async () => {
    if (!registrationId) {
      setError('Please enter a user ID');
      return;
    }

    mutate({
      roundId, registrationId, competitionId, attempts,
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
              onChange={(_, { value }) => setRegistrationId(value)}
              options={competitors.toSorted((a, b) => a.id - b.id).map((p, i) => ({
                key: p.id,
                value: p.id,
                text: `${p.user.name} (${i + 1})`,
              }))}
            />

            {attempts.map((attempt, index) => (
              <Form.Input
                key={index}
                label={`Attempt ${index + 1}`}
                placeholder="Time in milliseconds or DNF"
                value={attempt === -1 ? 'DNF' : attempt}
                onChange={(e) => handleAttemptChange(index, e.target.value)}
              />
            ))}

            <Button primary onClick={handleSubmit}>Submit Results</Button>
          </Form>
        </Grid.Column>

        <Grid.Column width={12}>
          <Header>Live Results</Header>
          <ResultsTable results={results ?? []} eventId={eventId} competitors={competitors} />
        </Grid.Column>
      </Grid>
    </Segment>
  );
}
