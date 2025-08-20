"use client";

import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { useParams } from "next/navigation";
import useAPI from "@/lib/wca/useAPI";

function zeroedArrayOfSize(size) {
  return Array(size).fill(0);
}

export default function ResultPage() {
  const { roundId, competitionId } = useParams<{
    roundId: string;
    competitionId: string;
  }>();

  const api = useAPI();

  const { data: results, isLoading } = useQuery({
    queryKey: ["live-round", roundId],
    queryFn: () => api.GET(""),
  });
}

function AddResults() {
  const [registrationId, setRegistrationId] = useState("");
  const [attempts, setAttempts] = useState(zeroedArrayOfSize(solveCount));
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const queryClient = useQueryClient();

  const { data: results, isLoading } = useQuery({
    queryKey: ["live-round", roundId],
    queryFn: () => getRoundResults(roundId, competitionId),
  });

  const handleRegistrationIdChange = useCallback(
    (_, { value }) => {
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
    mutationFn: submitRoundResults,
    onSuccess: () => {
      setSuccess("Results added successfully!");
      setRegistrationId("");
      setAttempts(zeroedArrayOfSize(solveCount));
      setError("");

      setTimeout(() => setSuccess(""), 3000);
    },
    onError: () => {
      setError("Failed to submit results. Please try again.");
    },
  });

  const { mutate: mutateUpdate, isPending: isPendingUpdate } = useMutation({
    mutationFn: updateRoundResults,
    onSuccess: () => {
      setSuccess("Results added successfully!");
      setRegistrationId("");
      setAttempts(zeroedArrayOfSize(solveCount));
      setError("");

      setTimeout(() => setSuccess(""), 3000);
    },
    onError: () => {
      setError("Failed to submit results. Please try again.");
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

  const handleSubmit = async () => {
    if (!registrationId) {
      setError("Please enter a user ID");
      return;
    }

    if (results.find((r) => r.registration_id === registrationId)) {
      mutateUpdate({
        roundId,
        registrationId,
        competitionId,
        attempts,
      });
    } else {
      mutateSubmit({
        roundId,
        registrationId,
        competitionId,
        attempts,
      });
    }
  };

  return (
    <Segment loading={isLoading || isPendingSubmit || isPendingUpdate}>
      <Grid>
        <Grid.Column width={4}>
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
        </Grid.Column>

        <Grid.Column width={12}>
          <Button.Group floated="right">
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
          </Button.Group>
          <Header>Live Results</Header>
          <ResultsTable
            results={results ?? []}
            event={event}
            competitors={competitors}
            competitionId={competitionId}
            isAdmin
          />
        </Grid.Column>
      </Grid>
    </Segment>
  );
}
