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

export const rankingCellStyle = (result) => {
  if (!result) {
    return {};
  }
  if (result.advancing) {
    return { backgroundColor: 'rgb(0, 230, 118)' };
  }

  if (result.advancing_questionable) {
    return { backgroundColor: 'rgba(0, 230, 118, 0.5)' };
  }

  return {};
};

export default function ResultsTable({
  results, event, competitors, competitionId, isAdmin = false, showEmpty = true,
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
    <Table basic="very" compact="very">
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell textAlign="right">#</Table.HeaderCell>
          { isAdmin && <Table.HeaderCell>Id</Table.HeaderCell> }
          <Table.HeaderCell>Competitor</Table.HeaderCell>
          {attemptIndexes.map((num) => (
            <Table.HeaderCell key={num} textAlign="right">
              {num + 1}
            </Table.HeaderCell>
          ))}
          <Table.HeaderCell textAlign="right">Average</Table.HeaderCell>
          <Table.HeaderCell textAlign="right">Best</Table.HeaderCell>
        </Table.Row>
      </Table.Header>

      <Table.Body>
        {sortedCompetitors.map((competitor, index) => {
          const potentialResults = resultsByRegistrationId[competitor.id];

          const hasResults = Boolean(potentialResults);
          const result = hasResults ? potentialResults[0] : null;

          if (!showEmpty && !hasResults) {
            return null;
          }

          return (
            <Table.Row key={competitor.user_id}>
              <Table.Cell width={1} textAlign="right" style={rankingCellStyle(result)}>
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
              {hasResults && result.attempts.map((attempt) => (
                <Table.Cell
                  textAlign="right"
                  key={`${competitor.user_id}-${attempt.attempt_number}`}
                >
                  {formatAttemptResult(attempt.result, event.id)}
                </Table.Cell>
              ))}
              {hasResults && (
              <>
                <Table.Cell textAlign="right">
                  {formatAttemptResult(result.average, event.id)}
                  {' '}
                  {!isAdmin && result.average_record_tag}
                </Table.Cell>
                <Table.Cell textAlign="right">
                  {formatAttemptResult(result.best, event.id)}
                  {!isAdmin && result.single_record_tag}
                </Table.Cell>
              </>
              )}
            </Table.Row>
          );
        })}
      </Table.Body>
    </Table>
  );
}
