import { serverClient } from "@/lib/wca/wcaAPI";

import { cache } from "react";

// There is no per-tab endpoint, so every custom tab route fetches the whole list to render one
//   entry. `cache` only dedupes within a request, and force-dynamic in (wca)/layout.tsx would
//   normally drop the fetch cache too - an explicit `revalidate` is the one fetch config it does
//   not override, so the list costs one Rails call per minute rather than one per tab view.
export const getTabs = cache(async (competitionId: string) => {
  return await serverClient.GET("/v0/competitions/{competitionId}/tabs", {
    params: { path: { competitionId } },
    next: { revalidate: 60 },
  });
});
