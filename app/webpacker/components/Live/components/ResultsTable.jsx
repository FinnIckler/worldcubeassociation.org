import { Table } from 'semantic-ui-react';
import React from 'react';
import { formatAttemptResult } from '../../../lib/wca-live/attempts';
import { events } from '../../../lib/wca-data.js.erb';

export default function ResultsTable({ results, eventId, wcif }) {
  const event = events.byId[eventId];

  return (
    <Table celled>
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell>Competitor</Table.HeaderCell>
          {[...Array(event.recommendedFormat().expectedSolveCount).keys()].map((num) => (
            <Table.HeaderCell key={num}>
              {num + 1}
            </Table.HeaderCell>
          ))}
        </Table.Row>
      </Table.Header>

      <Table.Body>
        {(results).map((result) => {
          const competitor = wcif.persons.find((p) => p.wcaUserId === result.user_id);
          return (
            <Table.Row key={competitor.wcaId}>
              <Table.Cell><a href={`/competitions/${wcif.id}/live/competitors/${competitor.registration.wcaRegistrationId}`}>{competitor.name}</a></Table.Cell>
              {result.attempts.map((attempt, attemptIndex) => (
                <Table.Cell key={attemptIndex}>{formatAttemptResult(attempt, eventId)}</Table.Cell>
              ))}
            </Table.Row>
          );
        })}
      </Table.Body>
    </Table>
  );
}
