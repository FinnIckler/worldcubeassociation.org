export function roundResultsKey(roundId: string, competitionId: string) {
  return ["live-round", roundId, competitionId];
}
