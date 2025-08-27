import { getRounds } from "@/lib/wca/competitions/getRounds";
import { Card, Link, List, Stack } from "@chakra-ui/react";
import events from "@/lib/wca/data/events";
import { parseActivityCode } from "@wca/helpers";
import { route } from "nextjs-routes";
import _ from "lodash";

export default async function AdminSchedulePage({
  params,
}: {
  params: Promise<{ competitionId: string }>;
}) {
  const { competitionId } = await params;

  const rounds = (await getRounds(competitionId)).data!;
  const roundsById = _.groupBy(
    rounds,
    (round) => parseActivityCode(round.id).eventId,
  );
  return (
    <Stack gap="4" direction="row" wrap="wrap">
      {_.map(roundsById, (rounds, key) => (
        <Card.Root key={key}>
          <Card.Body>
            <Card.Header>{events.byId[key].name}</Card.Header>
            <List.Root>
              {rounds.map((round) => (
                <List.Item key={round.round_id}>
                  <Link
                    href={route({
                      pathname:
                        "/competitions/[competitionId]/live/rounds/[roundId]/admin",
                      query: {
                        roundId: round.round_id.toString(),
                        competitionId,
                      },
                    })}
                  >
                    {round.id}
                  </Link>{" "}
                  ({round.results.length}/{round.competitors.length})
                </List.Item>
              ))}
            </List.Root>
          </Card.Body>
        </Card.Root>
      ))}
    </Stack>
  );
}
