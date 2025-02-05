import React from 'react';
import _ from 'lodash';
import { Table } from 'semantic-ui-react';
import { DateTime } from 'luxon';
import { formatAttemptResult } from '../../lib/wca-live/attempts';
import I18n from '../../lib/i18n';
import { countries } from '../../lib/wca-data.js.erb';
import {
  AttemptsCells,
  CompetitionCell,
  CountryCell,
  EventCell,
  PersonCell,
} from './TableCells';

function resultAttempts(result) {
  const attempts = [result?.value1, result?.value2, result?.value3, result?.value4, result?.value5]
    .filter(Boolean);

  const bestResult = _.max(attempts);
  const worstResult = _.min(attempts);

  const bestResultIndex = attempts.indexOf(bestResult);
  const worstResultIndex = attempts.indexOf(worstResult);

  return [attempts, bestResultIndex, worstResultIndex];
}

export const resultsFiveWideColumn = {
  accessorKey: 'result',
  header: I18n.t('results.table_elements.solves'),
  colSpan: 5,
  cell: ({ getValue }) => {
    const result = getValue();

    const [attempts, bestResultIndex, worstResultIndex] = resultAttempts(result);

    return (
      <AttemptsCells
        attempts={attempts}
        bestResultIndex={bestResultIndex}
        worstResultIndex={worstResultIndex}
        eventId={result.eventId}
      />
    );
  },
};

export const competitionColumn = {
  accessorKey: 'competition',
  header: I18n.t('results.table_elements.competition'),
  cell: ({ getValue }) => (
    <CompetitionCell
      competition={getValue()}
      compatIso2={countries.byId[getValue().countryId]?.iso2}
    />
  ),
};

export const regionColumn = {
  accessorKey: 'country',
  header: I18n.t('results.table_elements.region'),
  cell: ({ getValue }) => (
    <CountryCell country={getValue()} />
  ),
};

export const representingColumn = {
  accessorKey: 'country',
  header: I18n.t('results.table_elements.region'),
  cell: ({ getValue }) => (
    <CountryCell country={getValue()} />
  ),
};

export const attemptResultColumn = {
  accessorKey: 'result.value',
  header: I18n.t('results.table_elements.result'),
  cell: ({ row, getValue }) => (
    <Table.Cell>
      {formatAttemptResult(getValue(), row.original.result.eventId)}
    </Table.Cell>
  ),
};

export const personColumn = {
  accessorKey: 'result.name',
  header: I18n.t('results.table_elements.name'),
  cell: ({ row }) => (
    <PersonCell
      personId={row.original.result.personId}
      personName={row.original.result.personName}
    />
  ),
};

const eventColumn = {
  accessorKey: 'result.eventId',
  header: I18n.t('results.table_elements.event'),
  cell: ({ getValue }) => <EventCell eventId={getValue()} />,
};

export const rankColumn = {
  accessorKey: 'rank',
  header: '#',
  cell: ({ getValue }) => (
    <Table.Cell textAlign="center">{getValue()}</Table.Cell>
  ),
};

export const slimConfig = [
  {
    accessorKey: 'single.personName',
    header: I18n.t('results.table_elements.name'),
    cell: ({ row, getValue }) => (
      <PersonCell
        personId={row.original.single.personId}
        personName={getValue()}
      />
    ),
  },
  {
    accessorKey: 'single.value',
    header: I18n.t('common.single'),
    cell: ({ row, getValue }) => (
      <Table.Cell>
        {formatAttemptResult(getValue(), row.original.single.eventId)}
      </Table.Cell>
    ),
  },
  {
    accessorKey: 'single.eventId',
    header: I18n.t('results.table_elements.event'),
    cell: ({ getValue }) => <EventCell eventId={getValue()} />,
  },
  {
    accessorFn: (res) => res.average?.value,
    header: I18n.t('common.average'),
    cell: ({ row, getValue }) => (
      <Table.Cell>
        {getValue() && formatAttemptResult(getValue(), row.original.average?.eventId)}
      </Table.Cell>
    ),
  },
  {
    accessorFn: (res) => res.average?.personName,
    header: I18n.t('results.table_elements.name'),
    cell: ({ row, getValue }) => {
      if (getValue() === undefined) return <Table.Cell />;

      return (
        <PersonCell
          personId={row.original.average?.personId}
          personName={getValue()}
        />
      );
    },
  },
  {
    accessorFn: (res) => res.average,
    header: I18n.t('results.table_elements.solves'),
    colSpan: 5,
    cell: ({ getValue }) => {
      const result = getValue();

      if (!result) return <Table.Cell />;

      const [attempts, bestResultIndex, worstResultIndex] = resultAttempts(result);

      return (
        <AttemptsCells
          attempts={attempts}
          bestResultIndex={bestResultIndex}
          worstResultIndex={worstResultIndex}
          eventId={result.eventId}
        />
      );
    },
  },
];

export const separateRecordsConfig = (rankingType) => [
  eventColumn,
  attemptResultColumn,
  personColumn,
  regionColumn,
  competitionColumn,
  rankingType === 'average' && resultsFiveWideColumn,
].filter(Boolean);

export const historyConfig = (isMixed) => [
  {
    accessorKey: 'result.start_date',
    header: I18n.t('results.table_elements.date_circa'),
    cell: ({ getValue }) => (
      <Table.Cell>{DateTime.fromISO(getValue()).toFormat('MMM dd, yyyy')}</Table.Cell>
    ),
  },
  isMixed && eventColumn,
  personColumn,
  {
    accessorKey: 'result.value',
    header: I18n.t('common.single'),
    cell: ({ row, getValue }) => (
      <Table.Cell>
        {row.original.result.type === 'single' && formatAttemptResult(getValue(), row.original.result.eventId)}
      </Table.Cell>
    ),
  },
  {
    accessorKey: 'result.value',
    header: I18n.t('common.average'),
    cell: ({ row, getValue }) => (
      <Table.Cell>
        {row.original.result.type === 'average' && formatAttemptResult(getValue(), row.original.result.eventId)}
      </Table.Cell>
    ),
  },
  regionColumn,
  competitionColumn,
  resultsFiveWideColumn,
].filter(Boolean);

export const mixedRecordsConfig = [
  {
    accessorKey: 'result.type',
    header: I18n.t('results.selector_elements.type_selector.type'),
    cell: ({ getValue }) => (
      <Table.Cell>{I18n.t(`results.selector_elements.type_selector.${getValue()}`)}</Table.Cell>
    ),
  },
  personColumn,
  attemptResultColumn,
  regionColumn,
  competitionColumn,
  resultsFiveWideColumn,
];
