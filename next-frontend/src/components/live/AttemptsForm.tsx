import React, { useMemo } from "react";
import _ from "lodash";
import AttemptResultField from "../../EditResult/WCALive/AttemptResultField/AttemptResultField";
import { components } from "@/types/openapi";
import {Alert, Box, Heading} from "@chakra-ui/react";

interface AttemptsFormProps {
  registrationId: string;
  handleRegistrationIdChange: (
    event: React.SyntheticEvent<HTMLElement, Event>,
    data: any,
  ) => void;
  competitors: components["schemas"]["LiveCompetitor"][];
  solveCount: number;
  eventId: string;
  attempts: number[];
  handleAttemptChange: (index: number, value: number) => void;
  handleSubmit: () => void;
  error?: string;
  success?: string;
  header: string;
}

export default function AttemptsForm({
  registrationId,
  handleRegistrationIdChange,
  competitors,
  solveCount,
  eventId,
  attempts,
  handleAttemptChange,
  handleSubmit,
  error,
  success,
  header,
}: AttemptsFormProps) {
  const options = useMemo(
    () =>
      competitors.map((p) => ({
        key: p.id,
        value: p.id,
        registrationId: p.registrant_id,
        text: `${p.user.name} (${p.registrant_id})`,
      })),
    [competitors],
  );

  return (
    <Box>
      <Heading size="2xl">{header}</Heading>

      {error && <Alert.Root status="error" title={error} />}
      {success && <Alert.Root status="success" title={success} />}
      <Select
        label="Competitor"
        placeholder="Competitor"
        value={registrationId}
        deburr
        search={(inputs, value) =>
          inputs.filter(
            (d) =>
              d.text.includes(value) ||
              parseInt(value, 10) === d.registrationId,
          )
        }
        onChange={handleRegistrationIdChange}
        options={options}
      />
      {_.times(solveCount).map((index) => (
        <AttemptResultField
          eventId={eventId}
          key={index}
          label={`Attempt ${index + 1}`}
          placeholder="Time in milliseconds or DNF"
          value={attempts[index] ?? 0}
          onChange={(value) => handleAttemptChange(index, value)}
        />
      ))}
      <Form.Button primary onClick={handleSubmit}>
        Submit Results
      </Form.Button>
    </Form>
  );
}
