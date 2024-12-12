import React from 'react';
import { DateTime } from 'luxon';
import I18n from '../../../lib/i18n';
import I18nHTMLTranslate from '../../I18nHTMLTranslate';
import Markdown from '../../Markdown';
import { getFullDateTimeString } from '../../../lib/utils/dates';
import AccountRequirement from './AccountRequirement';
import CompetitionSeriesRequirement from './CompetitionSeriesRequirement';
import RegistrationFeeRequirements from './RegistrationFeeRequirements';
import EventChangeDeadlineRequirements from './EventChangeDeadlineRequirements';
import OnTheSpotRegistrationRequirements from './OnTheSpotRegistrationRequirements';
import GuestRequirements from './GuestRequirements';

export default function RegistrationRequirements({ competition, userInfo, showLinksToRegisterPage = false }) {
  return (
    <div>
      {competition.use_wca_registration && (
        <div>
          <AccountRequirement userInfo={userInfo} />
          {showLinksToRegisterPage ? (
            <I18nHTMLTranslate
              i18nKey="competitions.competition_info.register_link_html"
              options={{
                here: `<a href='/competitions/${competition.id}/register'>${I18n.t('common.here')}</a>`,
              }}
            />
          ) : (
            <p>{I18n.t('competitions.competition_info.register_below_html')}</p>
          )}
        </div>
      )}

      {competition.external_registration_page && (
        <p
          dangerouslySetInnerHTML={{
            __html: I18n.t('competitions.competition_info.register_link_html', {
              here: `<a href='${competition.external_registration_page}' target='_blank'>${I18n.t('common.here')}</a>`,
            }),
          }}
        />
      )}

      {competition['part_of_competition_series?'] && (
        <CompetitionSeriesRequirement competition={competition} />
      )}

      {I18n.t(
        competition.competitor_limit_enabled
          ? 'competitions.competition_info.competitor_limit_is'
          : 'competitions.competition_info.no_competitor_limit',
        { competitor_limit: competition.competitor_limit },
      )}

      {competition['has_fees?'] && <RegistrationFeeRequirements competition={competition} /> }

      {competition['using_payment_integrations?'] && (
        <I18nHTMLTranslate
          i18nKey={showLinksToRegisterPage
            ? 'competitions.competition_info.use_stripe_link_html'
            : 'competitions.competition_info.use_stripe_below_html'}
          options={{
            here: `<a href='/competitions/${competition.id}/register'>${I18n.t(
              'common.here',
            )}</a>`,
          }}
        />
      )}
      <br />
      {competition.refund_policy_percent || !competition['has_fees?']
        ? I18n.t('competitions.competition_info.refund_policy_html', {
          refund_policy_percent: `${competition.refund_policy_percent}%`,
          limit_date_and_time:
            getFullDateTimeString(DateTime.fromISO(competition.refund_policy_limit_date)),
        })
        : I18n.t('competitions.competition_info.no_refunds')}
      <br />
      {competition.waiting_list_deadline_date
        && (
          <>
            {I18n.t(
              'competitions.competition_info.waiting_list_deadline_html',
              {
                waiting_list_deadline:
                  getFullDateTimeString(DateTime.fromISO(competition.waiting_list_deadline_date)),
              },
            )}
            <br />
          </>
        )}
      {competition.competition_events.length > 1 && competition['has_event_change_deadline_date?'] && (
        <EventChangeDeadlineRequirements competition={competition} />
      )}
      <br />

      {competition['on_the_spot_registration?'] ? (
        <OnTheSpotRegistrationRequirements competition={competition} />)
        : I18n.t('competitions.competition_info.no_on_the_spot_registration')}
      <br />
      <GuestRequirements competition={competition} />

      {competition['guests_per_registration_limit_enabled?'] && (
        <>
          {I18n.t('competitions.competition_info.guest_limit', { count: competition.guests_per_registration_limit })}
          <br />
        </>
      )}

      {competition['uses_qualification?'] && !competition.allow_registration_without_qualification && (
        <>
          {I18n.t('competitions.competition_info.require_qualification')}
          <br />
        </>
      )}

      {competition['events_per_registration_limit_enabled?'] && (
        <>
          {I18n.t('competitions.competition_info.event_limit', { count: competition.events_per_registration_limit })}
          )
          <br />
        </>
      )}
      <br />
      {competition.extra_registration_requirements && (
        <Markdown md={competition.extra_registration_requirements} id="competition-info-extra-requirements" />
      )}
    </div>
  );
}