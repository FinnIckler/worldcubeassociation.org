"use client";

import { useMemo, useState } from "react";
import { useParams } from "next/navigation";
import useAPI from "@/lib/wca/useAPI";
import { useMutation, useQuery } from "@tanstack/react-query";
import Loading from "@/components/ui/loading";
import PermissionCheck from "@/components/PermissionCheck";
import { CurrentEventId, parseActivityCode } from "@wca/helpers";
import { components } from "@/types/openapi";
import events from "@/lib/wca/data/events";
import _ from "lodash";
import { roundResultsKey } from "@/lib/wca/competitions/live/helpers";
import { Button, Card, Grid, GridItem } from "@chakra-ui/react";
import AttemptsForm from "@/components/live/AttemptsForm";

export default function DoubleCheckPage() {
  const { roundId, competitionId } =
    useParams<"/competitions/[competitionId]/live/rounds/[roundId]/admin/doubleCheck">();

  const api = useAPI();

  const { data: resultsRequest, isLoading } = useQuery({
    queryKey: roundResultsKey(roundId, competitionId),
    queryFn: () =>
      api.GET("/competitions/{competitionId}/rounds/{roundId}", {
        params: { path: { roundId, competitionId } },
      }),
    select: (data) => data.data,
  });

  if (isLoading) {
    return <Loading />;
  }

  const { results, id, competitors } = resultsRequest!;

  return (
    <PermissionCheck
      requiredPermission="canAdministerCompetition"
      item={competitionId}
    >
      <DoubleCheck
        competitionId={competitionId}
        competitors={competitors}
        results={results}
        roundId={roundId}
        eventId={parseActivityCode(id).eventId as CurrentEventId}
      />
    </PermissionCheck>
  );
}

function DoubleCheck({
  competitionId,
  competitors,
  results,
  roundId,
  eventId,
}: {
  results: components["schemas"]["LiveResult"][];
  eventId: CurrentEventId;
  roundId: string;
  competitionId: string;
  competitors: components["schemas"]["LiveCompetitor"][];
}) {
  const event = events.byId[eventId];
  const solveCount = event.recommendedFormat.expected_solve_count;
  const [currentIndex, setCurrentIndex] = useState(0);
  const [registrationId, setRegistrationId] = useState(competitors[0].id);
  const [attempts, setAttempts] = useState(_.times(solveCount, _.constant(0)));
  const api = useAPI();

  const { mutate: mutateUpdate, isPending: isPendingUpdate } = useMutation({
    mutationFn: () =>
      api.PATCH("/competitions/{competitionId}/rounds/{roundId}", {
        body: {
          attempts: attempts.map((attempt, index) => ({
            result: attempt,
            attempt_number: index,
          })),
          registration_id: registrationId!,
        },
        params: { path: { competitionId, roundId } },
      }),
  });

  const handleSubmit = async () => {
    mutateUpdate();
  };

  const handleAttemptChange = (index: number, value: number) => {
    const newAttempts = [...attempts];
    newAttempts[index] = value;
    setAttempts(newAttempts);
  };

  const handleRegistrationIdChange = (value: number) => {
    setRegistrationId(value);
  };

  const currentCompetitor: components["schemas"]["LiveCompetitor"] | undefined =
    useMemo(() => {
      if (results) {
        return competitors.find(
          (r) => r.id === results[currentIndex].registration_id,
        );
      }
      return undefined;
    }, [competitors, currentIndex, results]);

  const onPrevious = () => {
    setAttempts(results[currentIndex - 1].attempts.map((a) => a.result));
    setCurrentIndex((oldIndex) => oldIndex - 1);
  };

  const onNext = () => {
    setAttempts(results[currentIndex + 1].attempts.map((a) => a.result));
    setCurrentIndex((oldIndex) => oldIndex + 1);
  };

  if (isPendingUpdate) {
    return <Loading />;
  }

  return (
    <Grid templateColumns="repeat(16, 1fr)" gap="6">
      <GridItem colSpan={1} verticalAlign="middle">
        {currentIndex !== 0 && <Button onClick={onPrevious}>{"<"}</Button>}
      </GridItem>
      <GridItem colSpan={7}>
        <AttemptsForm
          registrationId={currentCompetitor?.registrant_id ?? null}
          handleAttemptChange={handleAttemptChange}
          handleSubmit={handleSubmit}
          handleRegistrationIdChange={handleRegistrationIdChange}
          header="Double Check Result"
          attempts={attempts}
          competitors={competitors}
          solveCount={solveCount}
          eventId={eventId}
          isPending={isPendingUpdate}
        />
      </GridItem>
      <GridItem colSpan={1} verticalAlign="middle">
        {currentIndex !== results.length - 1 && (
          <Button onClick={onNext}>{">"}</Button>
        )}
      </GridItem>
      <GridItem colSpan={7} textAlign="center" verticalAlign="middle">
        <Card.Root>
          <Card.Body>
            <Card.Header>
              {currentIndex + 1} of {results.length}
              <br />
              {roundId}
            </Card.Header>
            <Card.Title>Double-check</Card.Title>
            <Card.Description>
              Here you can iterate over results ordered by entry time (newest
              first). When doing double-check you can place a scorecard next to
              the form to quickly compare attempt results. For optimal
              experience make sure to always put entered/updated scorecard at
              the top of the pile.
            </Card.Description>
          </Card.Body>
        </Card.Root>
      </GridItem>
    </Grid>
  );
}
