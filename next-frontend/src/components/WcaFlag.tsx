import _TwFlag from "@/components/icons/flags/_TwFlag";
import countries from "@/lib/wca/data/countries";
import { chakra, type HTMLChakraProps } from "@chakra-ui/react";

import type { ReactNode } from "react";

// flag-icons ships a flag for every real country, but none for the WCA's
// fictive "Multiple Countries" regions.
const flaggedIso2s = new Set(countries.real.map((country) => country.iso2));

type WcaFlagProps = HTMLChakraProps<"span"> & {
  code?: string;
  fallback?: ReactNode;
};

const WcaFlag = ({ code, fallback = null, ...restProps }: WcaFlagProps) => {
  const iso2 = code?.toUpperCase();

  if (iso2 === "TW") {
    return (
      <chakra.span {...restProps}>
        <_TwFlag />
      </chakra.span>
    );
  }

  if (!iso2 || !flaggedIso2s.has(iso2)) {
    return fallback;
  }

  return (
    <chakra.span {...restProps} className={`fi fi-${iso2.toLowerCase()}`} />
  );
};

export default WcaFlag;
