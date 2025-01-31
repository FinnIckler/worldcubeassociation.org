import React from 'react';
import { Card, List, Segment } from 'semantic-ui-react';
import { liveUrls } from '../../lib/requests/routes.js.erb';
import { events } from '../../lib/wca-data.js.erb';

export default function TestSchedulePage({ competitionId, rounds }) {
  const roundsById = _.groupBy(rounds, 'event.id');

  return (
    <Segment>
      <Card.Group>
        {_.map(roundsById, (r, key) => (
          <Card>
            <Card.Header>
              {events.byId[key].name}
            </Card.Header>
            <Card.Content>
              <List>
                {r.map((round) => (
                  <List.Item>
                    <a href={liveUrls.roundResultsAdmin(competitionId, round.id)}>{round.name}</a>
                  </List.Item>
                ))}
              </List>
            </Card.Content>
          </Card>
        ))}
      </Card.Group>
    </Segment>
  );
}
