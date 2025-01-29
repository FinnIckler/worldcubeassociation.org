import React from 'react';
import { Card, Segment } from 'semantic-ui-react';
import { liveUrls } from '../../lib/requests/routes.js.erb';

export default function TestSchedulePage({ competitionId, rounds }) {
  return (
    <Segment>
      <Card.Group>
        {rounds.map((r) => (
          <Card link href={liveUrls.roundResults(competitionId, r.id)}>
            <Card.Header>
              {r.name}
            </Card.Header>
          </Card>
        ))}
      </Card.Group>
    </Segment>
  );
}
