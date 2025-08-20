import { Container, Heading } from "@chakra-ui/react";
import events from "@/lib/wca/data/events";

export default function PodiumsPage() {
  return (
    <Container>
      <Heading size="5xl">Podiums</Heading>
      {podiums.map((finalRound) => (
        <>
          <Heading size="2xl">{events.byId[finalRound.event_id].name}</Heading>
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
