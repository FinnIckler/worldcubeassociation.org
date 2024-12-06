import React, { useState } from 'react';
import {
  Accordion,
  Header,
  Icon,
  Checkbox, Segment,
} from 'semantic-ui-react';
import I18n from '../../lib/i18n';
import {
  personUrl,
} from '../../lib/requests/routes.js.erb';
import UpcomingCompetitionTable from './UpcomingCompetitionTable';
import PastCompetitionsTable from './PastCompetitionTable';

export default function MyCompetitions({ permissions, competitions, userInfo }) {
  const [isAccordionOpen, setIsAccordionOpen] = useState(false);
  const [shouldShowRegistrationStatus, setShouldShowRegistrationStatus] = useState(false);

  return (
    <>
      <Header>
        {I18n.t('competitions.my_competitions.title')}
      </Header>
      <p>
        {I18n.t('competitions.my_competitions.disclaimer')}
      </p>
      <UpcomingCompetitionTable
        competitions={competitions.futureCompetitions}
        permissions={permissions}
        registrationStatuses={competitions.registrationStatuses}
      />
      <Accordion fluid styled>
        <Accordion.Title
          active={isAccordionOpen}
          onClick={() => setIsAccordionOpen(!isAccordionOpen)}
        >
          {`${I18n.t('competitions.my_competitions.past_competitions')} (${competitions.pastCompetitions?.length ?? 0})`}
        </Accordion.Title>
        <Accordion.Content active={isAccordionOpen}>
          <PastCompetitionsTable
            permissions={permissions}
            competitions={competitions.pastCompetitions}
          />
        </Accordion.Content>
      </Accordion>
      <Segment>
        <a href={personUrl(userInfo.wca_id)}>{I18n.t('layouts.navigation.my_results')}</a>
      </Segment>
      <Header>
        <Icon name="bookmark" />
        {I18n.t('competitions.my_competitions.bookmarked_title')}
      </Header>
      <p>{I18n.t('competitions.my_competitions.bookmarked_explanation')}</p>
      <Checkbox
        checked={shouldShowRegistrationStatus}
        label={I18n.t('competitions.index.show_registration_status')}
        onChange={() => setShouldShowRegistrationStatus(!shouldShowRegistrationStatus)}
      />
      <UpcomingCompetitionTable
        competitions={competitions.bookmarkedCompetitions}
        registrationStatuses={competitions.registrationStatuses}
        shouldShowRegistrationStatus={shouldShowRegistrationStatus}
        permissions={permissions}
      />
    </>
  );
}
