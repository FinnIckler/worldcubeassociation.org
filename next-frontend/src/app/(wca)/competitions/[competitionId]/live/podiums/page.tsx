import { Container, Heading } from "@chakra-ui/react";
import LiveResultsTable from "@/components/live/LiveResultsTable";
import events from "@/lib/wca/data/events";
import { getPodiums } from "@/lib/wca/competitions/live/getPodiums";
import { parseActivityCode } from "@wca/helpers";
import { Fragment } from "react";

export default async function PodiumsPage({
  params,
}: {
  params: Promise<{ competitionId: string }>;
}) {
  const { competitionId } = await params;

  const podiumsRequest = await getPodiums(competitionId);

  const rounds = podiumsRequest.data!;

  return (
    <Container>
      <Heading size="5xl">Podiums</Heading>
      {rounds.map((finalRound) => {
        const eventId = parseActivityCode(finalRound.id).eventId;

        return (
          <Fragment key={finalRound.id}>
            <Heading size="2xl">{events.byId[eventId].name}</Heading>
            {finalRound.results.length > 0 ? (
              <LiveResultsTable
                results={finalRound.results}
                competitionId={competitionId}
                competitors={finalRound.competitors}
                eventId={eventId}
                showEmpty={false}
              />
            ) : (
              "Podiums to be determined"
            )}
          </Fragment>
        );
      })}
    </Container>
  );
}
