import { serverClient } from "@/lib/wca/wcaAPI";
import { toErrorDetails } from "@/components/ui/openapiError";

import { cacheLife } from "next/cache";

export async function getPersonCompetitions(wcaId: string) {
  "use cache";
  cacheLife("minutes");

  // `Response` cannot cross a `"use cache"` boundary, so we only keep the parts
  //   that `OpenapiError` renders.
  const result = await serverClient.GET("/v0/persons/{wca_id}/competitions", {
    params: { path: { wca_id: wcaId } },
  });

  return { ...result, response: toErrorDetails(result.response) };
}
