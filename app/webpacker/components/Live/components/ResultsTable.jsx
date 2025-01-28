import { Table } from 'semantic-ui-react';
import React, { useMemo } from 'react';
import _ from 'lodash';
import { formatAttemptResult } from '../../../lib/wca-live/attempts';
import { events } from '../../../lib/wca-data.js.erb';
import { liveUrls } from '../../../lib/requests/routes.js.erb';

const customOrderBy = (competitor, resultsByRegistrationId, sortBy) => {
  const competitorResults = resultsByRegistrationId[competitor.id];

  if (!competitorResults) {
    return competitor.id;
  }

  return competitorResults[0][sortBy];
};

export default function ResultsTable({
  results, eventId, competitors, competitionId,
}) {
  const event = events.byId[eventId];
  const resultsByRegistrationId = _.groupBy(results, 'registration_id');

  const sortedCompetitors = useMemo(() => {
    if (results.length === 0) {
      return [];
    }

    const { sortBy } = event.recommendedFormat();

    return _.orderBy(
      competitors,
      [
        (competitor) => customOrderBy(competitor, resultsByRegistrationId, sortBy === 'single' ? 'best' : 'average'),
        (competitor) => customOrderBy(competitor, resultsByRegistrationId, sortBy === 'single' ? 'average' : 'best')],
      ['asc', 'asc'],
    );
  }, [competitors, event, results.length, resultsByRegistrationId]);

  return (
    <Table celled compact="very">
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell>Rank</Table.HeaderCell>
          <Table.HeaderCell>Competitor</Table.HeaderCell>
          {[...Array(event.recommendedFormat().expectedSolveCount).keys()].map((num) => (
            <Table.HeaderCell key={num}>
              {num + 1}
            </Table.HeaderCell>
          ))}
          <Table.HeaderCell>Average</Table.HeaderCell>
          <Table.HeaderCell>Best</Table.HeaderCell>
        </Table.Row>
      </Table.Header>

      <Table.Body>
        {sortedCompetitors.map((competitor, index) => {
          const result = resultsByRegistrationId[competitor.id];

          return (
            <Table.Row key={competitor.user_id}>
              <Table.Cell>
                {index + 1}
              </Table.Cell>
              <Table.Cell><a href={liveUrls.personResults(competitionId, competitor.id)}>{competitor.user.name}</a></Table.Cell>
              {result && result[0].attempts.map((attempt, attemptIndex) => (
                <Table.Cell key={attemptIndex}>{formatAttemptResult(attempt, eventId)}</Table.Cell>
              ))}
              {result && (
              <>
                <Table.Cell>{formatAttemptResult(result[0].average, event.id)}</Table.Cell>
                <Table.Cell>{formatAttemptResult(result[0].best, event.id)}</Table.Cell>
              </>
              )}
            </Table.Row>
          );
        })}
      </Table.Body>
    </Table>
  );
}
