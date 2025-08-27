import { serverClient } from "@/lib/wca/wcaAPI";
import { cache } from "react";

export const getRounds = cache(async (competitionId: string) => {
  return await serverClient.GET("/competitions/{competitionId}/rounds", {
    params: { path: { competitionId } },
  });
});
