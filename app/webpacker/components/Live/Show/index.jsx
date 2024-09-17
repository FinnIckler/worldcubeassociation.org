import React, { useEffect } from 'react';
import { Header, Segment, Table } from 'semantic-ui-react';
import { createConsumer } from '@rails/actioncable';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import WCAQueryClientProvider from '../../../lib/providers/WCAQueryClientProvider';

function ShowResults({ competitionId, roundId }) {
  const { data: results, isLoading } = useQuery({
    queryKey: `${competitionId}-${roundId}-results`,
    queryFn: () => [],
  });

  const queryClient = useQueryClient();

  useEffect(() => {
    const cable = createConsumer();

    // Create subscription to the channel with competition and round IDs
    const subscription = cable.subscriptions.create(
      { channel: 'LiveResultsChannel', competition_id: competitionId, round_id: roundId },
      {
        received: (data) => {
          const parsedResults = JSON.parse(data.results);
          queryClient.setQueryData(`${competitionId}-${roundId}-results`, (oldData) => [...oldData, parsedResults]);
        },
      },
    );

    // Cleanup subscription when component unmounts or ids change
    return () => {
      subscription.unsubscribe();
    };
  }, [competitionId, roundId, queryClient]);

  if (isLoading) {
    return (
      <Segment>
        Loading...
      </Segment>
    );
  }

  return (
    <Segment>
      <Header>
        {competitionId}
        {' '}
        {roundId}
        {' '}
        Live results
      </Header>
      <Table>
        <Table.Header>
          <Table.HeaderCell>1</Table.HeaderCell>
          <Table.HeaderCell>2</Table.HeaderCell>
          <Table.HeaderCell>3</Table.HeaderCell>
          <Table.HeaderCell>4</Table.HeaderCell>
          <Table.HeaderCell>5</Table.HeaderCell>
        </Table.Header>
        <Table.Body>
          {results.map((result) => (
            <Table.Row key={result.id}>
              <Table.Cell>{result.attempt1}</Table.Cell>
              <Table.Cell>{result.attempt2}</Table.Cell>
              <Table.Cell>{result.attempt3}</Table.Cell>
              <Table.Cell>{result.attempt4}</Table.Cell>
              <Table.Cell>{result.attempt5}</Table.Cell>
            </Table.Row>
          ))}
        </Table.Body>
      </Table>
    </Segment>
  );
}

export default function Wrapper({ competitionId, roundId }) {
  return (
    <WCAQueryClientProvider>
      <ShowResults competitionId={competitionId} roundId={roundId} />
    </WCAQueryClientProvider>
  );
}
