import React from 'react';
import {
  Header, Segment, Table,
} from 'semantic-ui-react';
import { events } from '../../../lib/wca-data.js.erb';
import WCAQueryClientProvider from '../../../lib/providers/WCAQueryClientProvider';
import { formatAttemptResult } from '../../../lib/wca-live/attempts';

export default function Wrapper({
  results, user, competitionId,
}) {
  return (
    <WCAQueryClientProvider>
      <PersonResults results={results} user={user} competitionId={competitionId} />
    </WCAQueryClientProvider>
  );
}

function PersonResults({
  results, user, competitionId,
}) {
  const resultsById = _.groupBy(results, 'event_id');
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
                {[...Array(events.byId[key].recommendedFormat().expectedSolveCount).keys()].map((num) => (
                  <Table.HeaderCell key={num}>
                    {num + 1}
                  </Table.HeaderCell>
                ))}
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {results.map((r) => {
                const { round, attempts } = r;
                return (
                  <Table.Row>
                    <Table.Cell>
                      <a href={`/competitions/${competitionId}/live/rounds/${round.id}`}>
                        Round
                        {' '}
                        {round.number}
                      </a>
                    </Table.Cell>
                    {attempts.map((a) => (
                      <Table.Cell>
                        {formatAttemptResult(a, event)}
                      </Table.Cell>
                    ))}
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
