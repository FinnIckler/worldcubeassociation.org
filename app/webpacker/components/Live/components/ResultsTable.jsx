import { Table } from 'semantic-ui-react';
import React from 'react';
import { formatAttemptResult } from '../../../lib/wca-live/attempts';
import { events } from '../../../lib/wca-data.js.erb';

export default function ResultsTable({ results, eventId }) {
  const event = events.byId[eventId];

  return (
    <Table celled>
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell>User ID</Table.HeaderCell>
          {[...Array(event.recommendedFormat().expectedSolveCount).keys()].map((num) => (
            <Table.HeaderCell key={num}>
              Attempt
              {num}
            </Table.HeaderCell>
          ))}
        </Table.Row>
      </Table.Header>

      <Table.Body>
        {(results).map((result, index) => (
          <Table.Row key={`${result.user_id}-${index}`}>
            <Table.Cell>{result.user_id}</Table.Cell>
            {result.attempts.map((attempt, attemptIndex) => (
              <Table.Cell key={attemptIndex}>{formatAttemptResult(attempt, eventId)}</Table.Cell>
            ))}
          </Table.Row>
        ))}
      </Table.Body>
    </Table>
  );
}
