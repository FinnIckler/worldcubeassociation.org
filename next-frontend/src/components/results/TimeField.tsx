import { useState, useCallback, ChangeEvent } from "react";
import _ from "lodash";
import { DNF_KEYS, DNS_KEYS } from "./keybindings";
import {
  centisecondsToClockFormat,
  DNF_VALUE,
  DNS_VALUE,
  SKIPPED_VALUE,
} from "@/lib/wca/wcif/attempts";
import { Field, Input, InputProps } from "@chakra-ui/react";

function reformatInput(input: string) {
  const number = _.toInteger(input.replace(/\D/g, "")) || 0;
  if (number === 0) return "";
  const str = `00000000${number.toString().slice(0, 8)}`;
  const [, hh, mm, ss, cc] = str.match(/(\d\d)(\d\d)(\d\d)(\d\d)$/)!;
  return `${hh}:${mm}:${ss}.${cc}`.replace(/^[0:]*(?!\.)/g, "");
}

function inputToAttemptResult(input: string) {
  if (input === "") return SKIPPED_VALUE;
  if (input === "DNF") return DNF_VALUE;
  if (input === "DNS") return DNS_VALUE;
  const num = _.toInteger(input.replace(/\D/g, "")) || 0;
  return (
    Math.floor(num / 1000000) * 360000 +
    Math.floor((num % 1000000) / 10000) * 6000 +
    Math.floor((num % 10000) / 100) * 100 +
    (num % 100)
  );
}

function attemptResultToInput(attemptResult: number) {
  if (attemptResult === SKIPPED_VALUE) return "";
  if (attemptResult === DNF_VALUE) return "DNF";
  if (attemptResult === DNS_VALUE) return "DNS";
  return centisecondsToClockFormat(attemptResult);
}

function isValid(input: string) {
  return input === attemptResultToInput(inputToAttemptResult(input));
}

interface TimeFieldProps {
  value?: number;
  onChange: (value: number) => void;
  label: string;
  disabled?: boolean;
  TextFieldProps?: InputProps;
}
function TimeField({
  value,
  onChange,
  label,
  disabled,
  TextFieldProps = {},
}: TimeFieldProps) {
  const [prevValue, setPrevValue] = useState(value);
  const [draftInput, setDraftInput] = useState(attemptResultToInput(value!));

  // Sync draft value when the upstream value changes.
  // See AttemptResultField for detailed description.
  if (prevValue !== value) {
    setDraftInput(attemptResultToInput(value!));
    setPrevValue(value);
  }

  const handleChange = useCallback(
    (event: ChangeEvent) => {
      const key = event.nativeEvent.data;
      if (DNF_KEYS.includes(key)) {
        setDraftInput("DNF");
      } else if (DNS_KEYS.includes(key)) {
        setDraftInput("DNS");
      } else {
        setDraftInput(reformatInput(event.target.value));
      }
    },
    [setDraftInput],
  );

  const handleBlur = useCallback(() => {
    const attempt = isValid(draftInput)
      ? inputToAttemptResult(draftInput)
      : SKIPPED_VALUE;
    onChange(attempt);
    // Once we emit the change, reflect the initial state.
    setDraftInput(attemptResultToInput(value));
  }, [draftInput, onChange, setDraftInput, value]);

  return (
    <Field.Root>
      <Field.Label>{label}</Field.Label>
      <Input
        {...TextFieldProps}
        disabled={disabled}
        spellCheck={false}
        value={draftInput}
        onChange={handleChange}
        onBlur={handleBlur}
      />
    </Field.Root>
  );
}

export default TimeField;
