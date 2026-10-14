"use client";

import { useEffect, useState } from "react";
import { Box, Center } from "@chakra-ui/react";

type Vector = [number, number, number];
type Matrix = [Vector, Vector, Vector];

type Move = { axis: 0 | 1 | 2; layer: 1 | -1; quarterTurns: number };

const TURN_MS = 100;
const GAP_MS = 25;
const PAUSE_MS = 20;

const R = (quarterTurns: number): Move => ({ axis: 0, layer: 1, quarterTurns });
const U = (quarterTurns: number): Move => ({
  axis: 1,
  layer: -1,
  quarterTurns,
});
const F = (quarterTurns: number): Move => ({ axis: 2, layer: 1, quarterTurns });

const T_PERM = [
  R(1),
  U(1),
  R(-1),
  U(-1),
  R(-1),
  F(1),
  R(2),
  U(-1),
  R(-1),
  U(-1),
  R(1),
  U(1),
  R(-1),
  F(-1),
];

const IDENTITY: Matrix = [
  [1, 0, 0],
  [0, 1, 0],
  [0, 0, 1],
];

const CUBIES: Vector[] = [-1, 0, 1]
  .flatMap((x) =>
    [-1, 0, 1].flatMap((y) => [-1, 0, 1].map((z): Vector => [x, y, z])),
  )
  .filter((position) => position.some((coordinate) => coordinate !== 0));

const FACES = [
  { axis: 2, side: 1, color: "green.cubeShades.top", transform: "" },
  {
    axis: 2,
    side: -1,
    color: "blue.cubeShades.top",
    transform: "rotateY(180deg)",
  },
  {
    axis: 0,
    side: 1,
    color: "red.cubeShades.top",
    transform: "rotateY(90deg)",
  },
  {
    axis: 0,
    side: -1,
    color: "orange.cubeShades.top",
    transform: "rotateY(-90deg)",
  },
  {
    axis: 1,
    side: -1,
    color: "wcaWhite.cubeShades.top",
    transform: "rotateX(90deg)",
  },
  {
    axis: 1,
    side: 1,
    color: "yellow.cubeShades.top",
    transform: "rotateX(-90deg)",
  },
];

const moveAngle = ({ layer, quarterTurns }: Move) => 90 * quarterTurns * layer;

const rotationMatrix = (move: Move): Matrix => {
  const radians = (moveAngle(move) * Math.PI) / 180;
  const cos = Math.round(Math.cos(radians));
  const sin = Math.round(Math.sin(radians));

  switch (move.axis) {
    case 0:
      return [
        [1, 0, 0],
        [0, cos, -sin],
        [0, sin, cos],
      ];
    case 1:
      return [
        [cos, 0, sin],
        [0, 1, 0],
        [-sin, 0, cos],
      ];
    case 2:
      return [
        [cos, -sin, 0],
        [sin, cos, 0],
        [0, 0, 1],
      ];
  }
};

const multiply = (a: Matrix, b: Matrix): Matrix =>
  a.map((row) =>
    b[0].map((_, col) =>
      row.reduce((sum, value, k) => sum + value * b[k][col], 0),
    ),
  ) as Matrix;

const apply = (matrix: Matrix, vector: Vector) =>
  matrix.map((row) =>
    row.reduce((sum, value, k) => sum + value * vector[k], 0),
  );

const toMatrix3d = (m: Matrix) =>
  `matrix3d(${m[0][0]}, ${m[1][0]}, ${m[2][0]}, 0, ${m[0][1]}, ${m[1][1]}, ${m[2][1]}, 0, ${m[0][2]}, ${m[1][2]}, ${m[2][2]}, 0, 0, 0, 0, 1)`;

const isInLayer = (orientation: Matrix, home: Vector, move: Move) =>
  apply(orientation, home)[move.axis] === move.layer;

export default function Loading() {
  const [orientations, setOrientations] = useState<Matrix[]>(
    CUBIES.map(() => IDENTITY),
  );
  const [step, setStep] = useState(0);
  const [turning, setTurning] = useState(false);

  const move = T_PERM[step];

  useEffect(() => {
    if (!turning) {
      const timeout = setTimeout(
        () => setTurning(true),
        step === 0 ? PAUSE_MS : GAP_MS,
      );
      return () => clearTimeout(timeout);
    }

    const timeout = setTimeout(() => {
      setOrientations((previous) =>
        previous.map((orientation, i) =>
          isInLayer(orientation, CUBIES[i], move)
            ? multiply(rotationMatrix(move), orientation)
            : orientation,
        ),
      );
      setStep((previous) => (previous + 1) % T_PERM.length);
      setTurning(false);
    }, TURN_MS + GAP_MS);
    return () => clearTimeout(timeout);
  }, [turning, step, move]);

  const axisVector = [0, 1, 2].map((axis) => (axis === move.axis ? 1 : 0));

  return (
    <Center py="12" css={{ "--cubie": "{sizes.5}" }}>
      <Box
        position="relative"
        boxSize="calc(var(--cubie) * 3)"
        transformStyle="preserve-3d"
        transform="rotateX(-30deg) rotateY(-45deg)"
      >
        {CUBIES.map((home, i) => {
          const isTurning = turning && isInLayer(orientations[i], home, move);

          return (
            <Box
              key={home.join()}
              position="absolute"
              top="var(--cubie)"
              insetStart="var(--cubie)"
              boxSize="var(--cubie)"
              transformStyle="preserve-3d"
              transform={`rotate3d(${axisVector.join()}, ${isTurning ? moveAngle(move) : 0}deg) ${toMatrix3d(orientations[i])} translate3d(${home.map((c) => `calc(var(--cubie) * ${c})`).join()})`}
              transition={
                isTurning ? `transform ${TURN_MS}ms ease-in-out` : "none"
              }
            >
              {FACES.map(({ axis, side, color, transform }) => (
                <Box
                  key={`${axis}${side}`}
                  position="absolute"
                  inset="0"
                  p="0.5"
                  bg="black"
                  transform={`${transform} translateZ(calc(var(--cubie) / 2))`}
                >
                  {home[axis] === side && (
                    <Box boxSize="full" bg={color} borderRadius="xs" />
                  )}
                </Box>
              ))}
            </Box>
          );
        })}
      </Box>
    </Center>
  );
}
