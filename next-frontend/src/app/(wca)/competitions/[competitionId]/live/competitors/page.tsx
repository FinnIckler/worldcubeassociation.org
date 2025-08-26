import { redirect } from "next/navigation";
import { route } from "nextjs-routes";

export default async function LiveCompetitors({
  params,
}: {
  params: Promise<{ competitionId: string }>;
}) {
  const { competitionId } = await params;
  // TODO: Redirect to /competitors
  redirect(
    route({
      pathname: "/competitions/[competitionId]",
      query: { competitionId },
    }),
  );
}
