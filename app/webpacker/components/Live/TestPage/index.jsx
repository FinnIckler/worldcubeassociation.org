import React, { useState, useEffect } from 'react';
import {
  Form, Table, Grid, Button, Message, Header, Segment,
} from 'semantic-ui-react';
import { createConsumer } from '@rails/actioncable';
import { useQueryClient } from '@tanstack/react-query';
import { formatAttemptResult } from '../../../lib/wca-live/attempts';
import { fetchWithAuthenticityToken } from '../../../lib/requests/fetchWithAuthenticityToken';
import { events } from '../../../lib/wca-data.js.erb';
import WCAQueryClientProvider from '../../../lib/providers/WCAQueryClientProvider';

export default function Wrapper({ competitionId, roundId, eventId }) {
  return (
    <WCAQueryClientProvider>
      <AddResults competitionId={competitionId} roundId={roundId} eventId={eventId} />
    </WCAQueryClientProvider>
  );
}

function AddResults({ competitionId, roundId, eventId }) {
  const [userId, setUserId] = useState('');
  const [attempts, setAttempts] = useState(['', '', '', '', '']);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [results, setResults] = useState([]);
  const queryClient = useQueryClient();

  useEffect(() => {
    const cable = createConsumer();

    const subscription = cable.subscriptions.create(
      { channel: 'LiveResultsChannel', round_id: roundId },
      {
        received: (data) => {
          queryClient.setQueryData(`${roundId}-results`, (oldData = []) => [...oldData, data]);
          setResults((prev) => [...prev, data]);
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

    try {
      await fetchWithAuthenticityToken(`/competitions/${competitionId}/rounds/${roundId}`, {
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

      setSuccess('Results added successfully!');
      setUserId('');
      setAttempts(['', '', '', '', '']);
      setError('');

      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      setError('Failed to submit results. Please try again.');
    }
  };

  const formatTime = (time) => formatAttemptResult(time, eventId);

  return (
    <Segment>
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
          <h2>Live Results</h2>
          <Table celled>
            <Table.Header>
              <Table.Row>
                <Table.HeaderCell>User ID</Table.HeaderCell>
                {[1, 2, 3, 4, 5].map((num) => (
                  <Table.HeaderCell key={num}>
                    Attempt
                    {num}
                  </Table.HeaderCell>
                ))}
              </Table.Row>
            </Table.Header>

            <Table.Body>
              {results.map((result, index) => (
                <Table.Row key={`${result.user_id}-${index}`}>
                  <Table.Cell>{result.user_id}</Table.Cell>
                  {result.attempts.map((attempt, attemptIndex) => (
                    <Table.Cell key={attemptIndex}>{formatTime(attempt)}</Table.Cell>
                  ))}
                </Table.Row>
              ))}
            </Table.Body>
          </Table>
        </Grid.Column>
      </Grid>
    </Segment>
  );
}
