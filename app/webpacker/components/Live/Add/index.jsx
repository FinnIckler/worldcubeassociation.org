import React, { useCallback } from 'react';
import {
  Label, Header, Segment, Form,
} from 'semantic-ui-react';
import { fetchWithAuthenticityToken } from '../../../lib/requests/fetchWithAuthenticityToken';
import useInputState from '../../../lib/hooks/useInputState';

const randomInt = () => Math.ceil(Math.random() * 10);

export default function AddResults({ roundId }) {
  const [attempt1, setAttempt1] = useInputState(randomInt());
  const [attempt2, setAttempt2] = useInputState(randomInt());
  const [attempt3, setAttempt3] = useInputState(randomInt());
  const [attempt4, setAttempt4] = useInputState(randomInt());
  const [attempt5, setAttempt5] = useInputState(randomInt());
  const onSubmit = useCallback(async (event) => {
    event.preventDefault();
    await fetchWithAuthenticityToken(`/live/${roundId}/add`, {
      body:
        JSON.stringify({
          results: {
            attempt1, attempt2, attempt3, attempt4, attempt5,
          },
        }),
      headers: {
        'Content-Type': 'application/json',
      },
      method: 'POST',
    });
    setAttempt1(randomInt());
    setAttempt2(randomInt());
    setAttempt3(randomInt());
    setAttempt4(randomInt());
    setAttempt5(randomInt());
  }, [attempt1, attempt2, attempt3, attempt4, attempt5, roundId, setAttempt1, setAttempt2, setAttempt3, setAttempt4, setAttempt5]);
  return (
    <Segment>
      <Form onSubmit={onSubmit}>
        <Header>
          {roundId}
          {' '}
          Live results
        </Header>
        <Form.Field>
          <Label> Attempt 1 </Label>
          <Form.Input type="number" onChange={setAttempt1} value={attempt1} />
        </Form.Field>
        <Form.Field>
          <Label> Attempt 2 </Label>
          <Form.Input type="number" onChange={setAttempt2} value={attempt2} />
        </Form.Field>
        <Form.Field>
          <Label> Attempt 3 </Label>
          <Form.Input type="number" onChange={setAttempt3} value={attempt3} />
        </Form.Field>
        <Form.Field>
          <Label> Attempt 4 </Label>
          <Form.Input type="number" onChange={setAttempt4} value={attempt4} />
        </Form.Field>
        <Form.Field>
          <Label> Attempt 5 </Label>
          <Form.Input type="number" onChange={setAttempt5} value={attempt5} />
        </Form.Field>
        <Form.Button type="submit"> Add Time </Form.Button>
      </Form>
    </Segment>
  );
}
