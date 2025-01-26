import React, { useEffect } from 'react';
import {
  Grid, Header, Segment,
} from 'semantic-ui-react';
import { createConsumer } from '@rails/actioncable';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { fetchJsonOrError } from '../../../lib/requests/fetchWithAuthenticityToken';
import { events } from '../../../lib/wca-data.js.erb';
import WCAQueryClientProvider from '../../../lib/providers/WCAQueryClientProvider';
import ResultsTable from '../components/ResultsTable';

export default function Wrapper({ competitionId, roundId, eventId }) {
  return (
    <WCAQueryClientProvider>
      <ResultPage competitionId={competitionId} roundId={roundId} eventId={eventId} />
    </WCAQueryClientProvider>
  );
}

async function getRoundResults(roundId, competitionId) {
  const { data } = await fetchJsonOrError(`/api/competitions/${competitionId}/rounds/${roundId}`);
  return data;
}

function ResultPage({ competitionId, roundId, eventId }) {
  const queryClient = useQueryClient();

  const { data: results, isLoading } = useQuery({
    queryKey: `${roundId}-results`,
    queryFn: () => getRoundResults(roundId, competitionId),
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

  return (
    <Segment loading={isLoading}>
      <Header>
        Add Results for
        {competitionId}
        :
        {' '}
        {events.byId[eventId].name}
      </Header>
      <Grid>
        <Grid.Column width={16}>
          <Header>Live Results</Header>
          <ResultsTable results={results ?? []} eventId={eventId} />
        </Grid.Column>
      </Grid>
    </Segment>
  );
}
