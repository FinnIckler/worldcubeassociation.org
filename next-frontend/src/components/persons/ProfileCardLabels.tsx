"use client";

import { useT } from "@/lib/i18n/useI18n";
import CountryMap from "@/components/CountryMap";

// The only translated strings on the profile card. They read the locale on the client so that
//   the card itself can be cached instead of reaching for cookies through `getT`.
export function GenderLabel({ gender }: { gender?: string }) {
  const { t } = useT();

  return t(`enums.user.gender.${gender}`);
}

export function RegionLabel({ code }: { code: string }) {
  const { t } = useT();

  return <CountryMap code={code} t={t} />;
}
