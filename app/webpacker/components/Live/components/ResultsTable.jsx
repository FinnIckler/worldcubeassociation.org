import { Table } from 'semantic-ui-react';
import React, { useMemo } from 'react';
import _ from 'lodash';
import { formatAttemptResult } from '../../../lib/wca-live/attempts';
import { events } from '../../../lib/wca-data.js.erb';
import { editRegistrationUrl, liveUrls } from '../../../lib/requests/routes.js.erb';

const customOrderBy = (competitor, resultsByRegistrationId, sortBy) => {
  const competitorResults = resultsByRegistrationId[competitor.id];

  if (!competitorResults) {
    return competitor.id;
  }

  return competitorResults[0][sortBy];
};

export default function ResultsTable({
  results, event, competitors, competitionId, isAdmin = false,
}) {
  const resultsByRegistrationId = _.groupBy(results, 'registration_id');

  const sortedCompetitors = useMemo(() => {
    const { sortBy } = event.recommendedFormat();

    return _.orderBy(
      competitors,
      [
        (competitor) => customOrderBy(competitor, resultsByRegistrationId, sortBy === 'single' ? 'best' : 'average'),
        (competitor) => customOrderBy(competitor, resultsByRegistrationId, sortBy === 'single' ? 'average' : 'best')],
      ['asc', 'asc'],
    );
  }, [competitors, event, resultsByRegistrationId]);

  const solveCount = event.recommendedFormat().expectedSolveCount;
  const attemptIndexes = [...Array(solveCount).keys()];

  return (
    <Table celled compact="very">
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell>Rank</Table.HeaderCell>
          { isAdmin && <Table.HeaderCell>Id</Table.HeaderCell> }
          <Table.HeaderCell>Competitor</Table.HeaderCell>
          {attemptIndexes.map((num) => (
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
          const potentialResults = resultsByRegistrationId[competitor.id];

          const hasResults = Boolean(potentialResults);
          const result = hasResults ? potentialResults[0] : null;

          return (
            <Table.Row key={competitor.user_id} positive={hasResults && result.advancing}>
              <Table.Cell>
                {index + 1}
              </Table.Cell>
              {isAdmin && (
              <Table.Cell>
                {competitor.registration_id}
              </Table.Cell>
              )}
              <Table.Cell>
                <a href={isAdmin ? editRegistrationUrl(competitor.user_id, competitionId) : liveUrls.personResults(competitionId, competitor.id)}>
                  {competitor.user.name}
                </a>
              </Table.Cell>
              {hasResults && result.attempts.map((attempt, attemptIndex) => (
                <Table.Cell key={attemptIndex}>{formatAttemptResult(attempt.result, event.id)}</Table.Cell>
              ))}
              {hasResults && (
              <>
                <Table.Cell>{formatAttemptResult(result.average, event.id)}</Table.Cell>
                <Table.Cell>{formatAttemptResult(result.best, event.id)}</Table.Cell>
              </>
              )}
            </Table.Row>
          );
        })}
      </Table.Body>
    </Table>
  );
}
