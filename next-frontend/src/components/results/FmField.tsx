import { ChangeEvent, useCallback, useState } from "react";
import _ from "lodash";
import { DNF_VALUE, DNS_VALUE, SKIPPED_VALUE } from "@/lib/wca/wcif/attempts";
import { Field, Input, InputProps } from "@chakra-ui/react";
import { DNF_KEYS, DNS_KEYS } from "@/components/results/keybindings";

function numberToInput(number: number) {
  if (number === SKIPPED_VALUE) return "";
  if (number === DNF_VALUE) return "DNF";
  if (number === DNS_VALUE) return "DNS";
  return number.toString();
}

interface FmFieldProps {
  value: number;
  onChange: (value: number) => void;
  label: string;
  disabled?: boolean;
  TextFieldProps?: InputProps;
  resultType?: "single" | "average";
}

function FmField({
  value: rawValue,
  onChange,
  label,
  disabled,
  TextFieldProps = {},
  resultType = "single",
}: FmFieldProps) {
  const isAverage = resultType === "average";
  // 35 single is stored as 35, 35 average is stored as 3500
  const value = isAverage ? rawValue / 100 : rawValue;
  const [prevValue, setPrevValue] = useState(value);
  const [draftValue, setDraftValue] = useState(value);

  // Sync draft value when the upstream value changes.
  // See AttemptResultField for detailed description.
  if (prevValue !== value) {
    setDraftValue(value);
    setPrevValue(value);
  }

  const handleChange = useCallback(
    (event: ChangeEvent) => {
      const key = event.nativeEvent.data;
      if (DNF_KEYS.includes(key)) {
        setDraftValue(DNF_VALUE);
      } else if (DNS_KEYS.includes(key)) {
        setDraftValue(DNS_VALUE);
      } else {
        const newValue =
          _.toInteger(event.target.value.replace(/\D/g, "")) || SKIPPED_VALUE;
        setDraftValue(newValue);
      }
    },
    [setDraftValue],
  );

  const handleBlur = useCallback(() => {
    const parsedDraftValue = isAverage ? draftValue * 100 : draftValue;
    onChange(parsedDraftValue);
    // Once we emit the change, reflect the initial state.
    setDraftValue(value);
  }, [onChange, draftValue, setDraftValue, value, isAverage]);

  return (
    <Field.Root>
      <Field.Label>{label}</Field.Label>
      <Input
        {...TextFieldProps}
        disabled={disabled}
        spellCheck={false}
        value={numberToInput(draftValue)}
        onChange={handleChange}
        onBlur={handleBlur}
      />
    </Field.Root>
  );
}

export default FmField;
