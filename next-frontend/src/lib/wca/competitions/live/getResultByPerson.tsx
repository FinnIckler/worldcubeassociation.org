import { serverClient } from "@/lib/wca/wcaAPI";
import { cache } from "react";

export const getResultByPerson = cache(
  async (competitionId: string, registrationId: string) => {
    return await serverClient.GET(
      "/competitions/{competitionId}/registrations/{registrationId}",
      {
        params: { path: { competitionId, registrationId } },
      },
    );
  },
);
