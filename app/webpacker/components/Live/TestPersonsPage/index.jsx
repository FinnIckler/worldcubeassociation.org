import React from 'react';
import {
  Header, Segment, Table,
} from 'semantic-ui-react';
import { events } from '../../../lib/wca-data.js.erb';
import WCAQueryClientProvider from '../../../lib/providers/WCAQueryClientProvider';
import { formatAttemptResult } from '../../../lib/wca-live/attempts';
import { liveUrls } from '../../../lib/requests/routes.js.erb';
import { rankingCellStyle } from '../components/ResultsTable';

export default function Wrapper({
  results, user, competitionId,
}) {
  return (
    <WCAQueryClientProvider>
      <PersonResults allResults={results} user={user} competitionId={competitionId} />
    </WCAQueryClientProvider>
  );
}

function PersonResults({
  allResults, user, competitionId,
}) {
  const resultsById = _.groupBy(allResults, 'event_id');
  return (
    <Segment>
      <Header>
        {user.name}
      </Header>
      {_.map(resultsById, (results, key) => (
        <>
          <Header as="h3">{events.byId[key].name}</Header>
          <Table>
            <Table.Header>
              <Table.Row>
                <Table.HeaderCell>Round</Table.HeaderCell>
                <Table.HeaderCell>Rank</Table.HeaderCell>
                {[...Array(events.byId[key].recommendedFormat().expectedSolveCount).keys()].map((num) => (
                  <Table.HeaderCell key={num}>
                    {num + 1}
                  </Table.HeaderCell>
                ))}
                <Table.HeaderCell>Average</Table.HeaderCell>
                <Table.HeaderCell>Best</Table.HeaderCell>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {results.map((r) => {
                const { round, attempts } = r;
                return (
                  <Table.Row>
                    <Table.Cell width={1}>
                      <a href={liveUrls.roundResults(competitionId, round.id)}>
                        Round
                        {' '}
                        {round.number}
                      </a>
                    </Table.Cell>
                    <Table.Cell width={1} style={rankingCellStyle(r)}>{r.ranking}</Table.Cell>
                    {attempts.map((a) => (
                      <Table.Cell>
                        {formatAttemptResult(a.result, events.byId[key].id)}
                      </Table.Cell>
                    ))}
                    <Table.Cell>{formatAttemptResult(r.average, events.byId[key].id)}</Table.Cell>
                    <Table.Cell>{formatAttemptResult(r.best, events.byId[key].id)}</Table.Cell>
                  </Table.Row>
                );
              })}
            </Table.Body>
          </Table>
        </>
      ))}
    </Segment>
  );
}
