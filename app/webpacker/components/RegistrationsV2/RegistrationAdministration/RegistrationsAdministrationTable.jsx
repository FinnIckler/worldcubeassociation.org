import {
  Ref, Segment, Table, TableFooter,
} from 'semantic-ui-react';
import React from 'react';
import { DragDropContext, Droppable } from 'react-beautiful-dnd';
import i18n from '../../../lib/i18n';
import TableHeader from './AdministrationTableHeader';
import TableRow from './AdministrationTableRow';
import { currenciesData } from '../../../lib/wca-data.js.erb';

function FooterContent({
  registrations, competitionInfo,
  eventsToggled,
}) {
  const newcomerCount = registrations.filter(
    (reg) => reg.user.wca_id === undefined,
  ).length;

  const countryCount = new Set(
    registrations.map((reg) => reg.user.country.iso2),
  ).size;

  const guestCount = _.sum(registrations.map((r) => r.guests));

  const moneyCount = _.sum(registrations.filter(
    (r) => r.payment.payment,
  ).map((r) => r.payment.payment));

  const moneyCountHumanReadable = moneyCount
    / currenciesData.byIso[competitionInfo.currency_code].subunitToUnit;

  const eventCounts = Object.fromEntries(
    competitionInfo.event_ids.map((evt) => {
      const competingCount = registrations.filter(
        (reg) => reg.competing.event_ids.includes(evt),
      ).length;

      return [evt, competingCount];
    }),
  );

  const eventsSum = _.sum(Object.values(eventCounts));

  return (
    <Table.Row>
      <Table.Cell colSpan={4}>
        {`${newcomerCount} First-Timers + ${
          registrations.length - newcomerCount
        } Returners = ${registrations.length} People`}
      </Table.Cell>
      <Table.Cell>{`${countryCount}  Countries`}</Table.Cell>
      <Table.Cell />
      <Table.Cell>{`${currenciesData.byIso[competitionInfo.currency_code].symbol}${moneyCountHumanReadable} (${currenciesData.byIso[competitionInfo.currency_code].name})`}</Table.Cell>
      { eventsToggled ? competitionInfo.event_ids.map((evt) => (
        <Table.Cell key={`footer-count-${evt}`}>
          {eventCounts[evt]}
        </Table.Cell>
      )) : <Table.Cell>{eventsSum}</Table.Cell>}
      <Table.Cell>{guestCount}</Table.Cell>
      <Table.Cell />
      <Table.Cell />
      <Table.Cell />
      <Table.Cell />
    </Table.Row>
  );
}

export default function RegistrationAdministrationTable({
  columnsExpanded,
  registrations,
  selected,
  select,
  unselect,
  sortDirection,
  sortColumn,
  changeSortColumn,
  competitionInfo,
  draggable = false,
  sortable = true,
  handleOnDragEnd,
}) {
  const handleHeaderCheck = (_, data) => {
    if (data.checked) {
      select(registrations.map(({ user }) => user.id));
    } else {
      unselect(registrations.map(({ user }) => user.id));
    }
  };

  if (registrations.length === 0) {
    return (
      <Segment>
        {i18n.t('competitions.registration_v2.list.empty')}
      </Segment>
    );
  }
  // TODO: use native ref= when we switch to semantic v3
  /* eslint-disable react/jsx-props-no-spreading */
  return (
    <Table sortable={sortable} striped unstackable singleLine textAlign="left">
      <TableHeader
        columnsExpanded={columnsExpanded}
        isChecked={registrations.length === selected.length}
        onCheckboxChanged={handleHeaderCheck}
        sortDirection={sortDirection}
        sortColumn={sortColumn}
        changeSortColumn={changeSortColumn}
        competitionInfo={competitionInfo}
        draggable={draggable}
      />

      <DragDropContext onDragEnd={handleOnDragEnd}>
        <Droppable droppableId="droppable-table">
          {(providedDroppable) => (
            <Ref innerRef={providedDroppable.innerRef}>
              <Table.Body {...providedDroppable.droppableProps}>
                {registrations.map((w, i) => (
                  <TableRow
                    competitionInfo={competitionInfo}
                    columnsExpanded={columnsExpanded}
                    registration={w}
                    onCheckboxChange={(_, data) => {
                      if (data.checked) {
                        select([w.user.id]);
                      } else {
                        unselect([w.user.id]);
                      }
                    }}
                    index={i}
                    draggable={draggable}
                    isSelected={selected.includes(w.user.id)}
                  />
                ))}
                {providedDroppable.placeholder}
              </Table.Body>
            </Ref>
          )}
        </Droppable>
      </DragDropContext>
      <TableFooter>
        <FooterContent registrations={registrations} competitionInfo={competitionInfo} eventsToggled={columnsExpanded.events} />
      </TableFooter>
    </Table>
  );
}
