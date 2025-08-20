"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useCallback, useState } from "react";
import { useParams } from "next/navigation";
import useAPI from "@/lib/wca/useAPI";
import Loading from "@/components/ui/loading";
import { components } from "@/types/openapi";
import { CurrentEventId } from "@wca/helpers";
import events from "@/lib/wca/data/events";
import { Container, Grid, GridItem, Heading } from "@chakra-ui/react";

function zeroedArrayOfSize(size: number) {
  return Array(size).fill(0);
}

export default function ResultPage() {
  const { roundId, competitionId } = useParams<{
    roundId: string;
    competitionId: string;
  }>();

  const api = useAPI();

  const { data: results, isLoading } = useQuery({
    queryKey: ["live-round", roundId, competitionId],
    queryFn: () =>
      api.GET("/competitions/{competitionId}/rounds/{roundId}", {
        params: { path: { roundId, competitionId } },
      }),
    select: (data) => data.data,
  });

  if (isLoading) {
    return <Loading />;
  }

  return (
    <AddResults
      results={results!}
      eventId={results!.map((r) => r.event_id)[0] as CurrentEventId}
      roundId={roundId}
      competitionId={competitionId}
    />
  );
}

function AddResults({
  results,
  eventId,
  roundId,
  competitionId,
}: {
  results: components["schemas"]["LiveResult"][];
  eventId: CurrentEventId;
  roundId: string;
  competitionId: string;
}) {
  const event = events.byId[eventId];
  const solveCount = event.recommendedFormat.expected_solve_count;

  const [registrationId, setRegistrationId] = useState<number | null>(null);
  const [attempts, setAttempts] = useState<number[]>(
    zeroedArrayOfSize(solveCount),
  );
  const [error, setError] = useState<string>("");
  const [success, setSuccess] = useState<string>("");

  const queryClient = useQueryClient();

  const api = useAPI();

  const handleRegistrationIdChange = useCallback(
    (value: number) => {
      setRegistrationId(value);
      const alreadyEnteredResults = results.find(
        (r) => r.registration_id === value,
      );
      if (alreadyEnteredResults) {
        setAttempts(alreadyEnteredResults.attempts.map((a) => a.result));
      } else {
        setAttempts(zeroedArrayOfSize(solveCount));
      }
    },
    [results, solveCount],
  );

  const { mutate: mutateSubmit, isPending: isPendingSubmit } = useMutation({
    mutationFn: () =>
      api.POST("/competitions/{competitionId}/rounds/{roundId}", {
        body: {
          attempts: attempts.map((attempt, index) => ({
            result: attempt,
            attempt_number: index,
          })),
          registration_id: registrationId!,
        },
        params: { path: { competitionId, roundId } },
      }),
    onSuccess: () => {
      setSuccess("Results added successfully!");
      setRegistrationId(null);
      setAttempts(zeroedArrayOfSize(solveCount));
      setError("");

      setTimeout(() => setSuccess(""), 3000);
    },
    onError: () => {
      setError("Failed to submit results. Please try again.");
    },
  });

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
    onSuccess: () => {
      setSuccess("Results updated successfully!");
      setRegistrationId(null);
      setAttempts(zeroedArrayOfSize(solveCount));
      setError("");

      setTimeout(() => setSuccess(""), 3000);
    },
    onError: () => {
      setError("Failed to update results. Please try again.");
    },
  });

  const updateResultsData = useCallback(
    (data) => {
      queryClient.setQueryData(roundResultsKey(roundId), (oldData) =>
        insertNewResult(oldData, data),
      );
    },
    [queryClient, roundId],
  );

  useResultsSubscription(roundId, updateResultsData);

  const handleAttemptChange = (index, value) => {
    const newAttempts = [...attempts];
    newAttempts[index] = value;
    setAttempts(newAttempts);
  };

  const handleSubmit = () => {
    if (!registrationId) {
      setError("Please enter a user ID");
      return;
    }

    if (results.find((r) => r.registration_id === registrationId)) {
      mutateUpdate();
    } else {
      mutateSubmit();
    }
  };

  return (
    <Container>
      <Grid templateColumns="repeat(16, 1fr)" gap="6">
        <GridItem colSpan={4}>
          <AttemptsForm
            error={error}
            success={success}
            registrationId={registrationId}
            handleAttemptChange={handleAttemptChange}
            handleSubmit={handleSubmit}
            handleRegistrationIdChange={handleRegistrationIdChange}
            header="Add Result"
            attempts={attempts}
            competitors={competitors}
            solveCount={solveCount}
            eventId={eventId}
          />
        </GridItem>

        <GridItem colSpan={12}>
          <ButtonGroup float="right">
            <a href={liveUrls.roundResults(competitionId, roundId)}>
              <Button>Results</Button>
            </a>
            <a href={competitionEditRegistrationsUrl(competitionId)}>
              <Button>Add Competitor</Button>
            </a>
            <a href={liveUrls.roundResults(competitionId, roundId)}>
              <Button>PDF</Button>
            </a>
            <a href={liveUrls.checkRoundResultsAdmin(competitionId, roundId)}>
              <Button>Double Check</Button>
            </a>
          </ButtonGroup>
          <Heading size="5xl">Live Results</Heading>
          <ResultsTable
            results={results}
            event={event}
            competitors={competitors}
            competitionId={competitionId}
            isAdmin
          />
        </GridItem>
      </Grid>
    </Container>
  );
}
