function Podiums({ podiums, competitionId, competitors }) {
  return (
    <Container fluid>
      <Header>Podiums</Header>
      {podiums.map((finalRound) => (
        <>
          <Header as="h3">{events.byId[finalRound.event_id].name}</Header>
          {finalRound.live_podium.length > 0 ? (
            <ResultsTable
              results={finalRound.live_podium}
              competitionId={competitionId}
              competitors={competitors}
              event={events.byId[finalRound.event_id]}
            />
          ) : (
            "Podiums to be determined"
          )}
        </>
      ))}
    </Container>
  );
}
