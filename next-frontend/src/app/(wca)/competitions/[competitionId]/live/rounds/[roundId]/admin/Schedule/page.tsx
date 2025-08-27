export default async function AdminSchedulePage({
  params,
}: {
  params: Promise<{ competitionId: string }>;
}) {
  const { competitionId } = await params;

  const roundsById = _.groupBy(rounds, "event.id");
  return (
    <Segment>
      <Card.Group>
        {_.map(roundsById, (r, key) => (
          <Card>
            <Card.Header>{events.byId[key].name}</Card.Header>
            <Card.Content>
              <List>
                {r.map((round) => (
                  <List.Item key={round.id}>
                    <a
                      href={liveUrls.roundResultsAdmin(competitionId, round.id)}
                    >
                      {round.name}
                    </a>{" "}
                    ({round.competitors_live_results_entered}/
                    {round.total_accepted_registrations})
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
