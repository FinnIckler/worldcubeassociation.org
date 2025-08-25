"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useCallback, useState } from "react";
import { useParams } from "next/navigation";
import useAPI from "@/lib/wca/useAPI";
import Loading from "@/components/ui/loading";
import { components } from "@/types/openapi";
import { CurrentEventId, parseActivityCode } from "@wca/helpers";
import events from "@/lib/wca/data/events";
import {
  Button,
  ButtonGroup,
  Container,
  Grid,
  GridItem,
  Heading,
  Link,
  VStack,
} from "@chakra-ui/react";
import LiveResultsTable from "@/components/live/LiveResultsTable";
import AttemptsForm from "@/components/live/AttemptsForm";

function zeroedArrayOfSize(size: number) {
  return Array(size).fill(0);
}

function roundResultsKey(roundId: string, competitionId: string) {
  return ["live-round", roundId, competitionId];
}

function insertNewResult(
  roundResults: components["schemas"]["LiveResult"][],
  newResult: components["schemas"]["LiveResult"],
) {
  const { registration_id: updatedRegistrationId } = newResult;

  const untouchedResults = roundResults.filter(
    ({ registration_id: registrationId }) =>
      registrationId !== updatedRegistrationId,
  );

  return [...untouchedResults, newResult];
}

export default function ResultPage() {
  const { roundId, competitionId } = useParams<{
    roundId: string;
    competitionId: string;
  }>();

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
    <Container bg="bg">
      <VStack align="left">
        <Heading size="5xl">Live Results</Heading>
        <AddResults
          results={results!}
          eventId={parseActivityCode(id).eventId as CurrentEventId}
          roundId={roundId}
          competitionId={competitionId}
          competitors={competitors!}
        />
      </VStack>
    </Container>
  );
}

function AddResults({
  results,
  eventId,
  roundId,
  competitionId,
  competitors,
}: {
  results: components["schemas"]["LiveResult"][];
  eventId: CurrentEventId;
  roundId: string;
  competitionId: string;
  competitors: components["schemas"]["LiveCompetitor"][];
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
            attempt_number: index + 1,
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
    (data: components["schemas"]["LiveResult"]) => {
      queryClient.setQueryData(
        roundResultsKey(roundId, competitionId),
        (oldData: components["schemas"]["LiveResult"][]) =>
          insertNewResult(oldData, data),
      );
    },
    [competitionId, queryClient, roundId],
  );

  // useResultsSubscription(roundId, updateResultsData);

  const handleAttemptChange = (index: number, value: number) => {
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
          isPendingSubmit={isPendingSubmit}
        />
      </GridItem>

      <GridItem colSpan={12}>
        <ButtonGroup float="right">
          <Button asChild>
            <Link
              href={`/competitions/${competitionId}/live/rounds/${roundId}`}
            >
              Results
            </Link>
          </Button>
          <Button asChild>
            <Link href={`/competitions/${competitionId}/edit/registrations`}>
              Add Competitor
            </Link>
          </Button>
          <Button asChild>
            <Link
              href={`/competitions/${competitionId}/live/rounds/${roundId}/pdf`}
            >
              PDF
            </Link>
          </Button>
          <Button asChild>
            <Link
              href={`/competitions/${competitionId}/live/rounds/${roundId}/double-check`}
            >
              Double Check
            </Link>
          </Button>
        </ButtonGroup>
        <LiveResultsTable
          results={results}
          eventId={eventId}
          competitors={competitors}
          competitionId={competitionId}
          isAdmin
        />
      </GridItem>
    </Grid>
  );
}
