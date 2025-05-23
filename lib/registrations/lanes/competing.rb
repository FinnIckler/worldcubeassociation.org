# frozen_string_literal: true

module Registrations
  module Lanes
    module Competing
      def self.process!(lane_params, user_id, competition_id)
        registration = Registration.build(competition_id: competition_id,
                                          user_id: user_id,
                                          registered_at: Time.now.utc)

        # Apply all the information passed in by the user
        registration = Registrations::RegistrationChecker.apply_payload(registration, lane_params)

        changes = registration.changes.transform_values { |change| change[1] }
        changes[:event_ids] = registration.changed_event_ids

        registration.save!

        RegistrationsMailer.notify_organizers_of_new_registration(registration).deliver_later
        RegistrationsMailer.notify_registrant_of_new_registration(registration).deliver_later
        RegistrationsMailer.notify_delegates_of_formerly_banned_user_registration(registration).deliver_later if registration.user.banned_in_past?
        registration.add_history_entry(changes, "worker", user_id, "Worker processed")
      end

      def self.update_raw!(update_params, competition, acting_entity_id)
        user_id = update_params[:user_id]

        Registration.find_by(competition: competition, user_id: user_id)
                    .tap { self.update!(update_params, it, acting_entity_id) }
      end

      def self.update!(update_params, registration, acting_entity_id)
        registration = Registrations::RegistrationChecker.apply_payload(registration, update_params, clone: false)

        # Make sure that a waiting list always exists if you need one during the update
        registration.competition.create_waiting_list(entries: []) if registration.waitlistable? && !registration.waiting_list_persisted?

        ActiveRecord::Base.transaction do
          changes = registration.changes.transform_values { |change| change[1] }

          changes[:waiting_list_position] = registration.waiting_list_position if registration.waitlist_position_changed?
          changes[:event_ids] = registration.changed_event_ids if registration.changed_event_ids.present?

          registration.save!

          # Make Rails forget about any in-memory cached values of the `has_many :events` association.
          # This is (unfortunately) necessary even after a `save!`, because Rails still caches the association
          #   from when we called `event_ids` in the `apply_payload` method above.
          registration.events.reset

          history_action_type = Registrations::Helper.action_type(update_params, registration.user_id, acting_entity_id)

          if acting_entity_id == Registration::AUTO_ACCEPT_ENTITY_ID
            registration.add_history_entry(changes, Registration::SYSTEM_ENTITY_ID, acting_entity_id, history_action_type)
          else
            registration.add_history_entry(changes, Registration::USER_ENTITY_ID, acting_entity_id, history_action_type)
          end
        end

        send_status_change_email(registration, acting_entity_id) if registration.competing_status_previously_changed?
      end

      def self.send_status_change_email(registration, acting_entity_id)
        case registration.competing_status
        when Registrations::Helper::STATUS_WAITING_LIST
          RegistrationsMailer.notify_registrant_of_waitlisted_registration(registration).deliver_later
        when Registrations::Helper::STATUS_PENDING
          RegistrationsMailer.notify_registrant_of_new_registration(registration).deliver_later
        when Registrations::Helper::STATUS_ACCEPTED
          RegistrationsMailer.notify_registrant_of_accepted_registration(registration).deliver_later
        when Registrations::Helper::STATUS_REJECTED, Registrations::Helper::STATUS_DELETED, Registrations::Helper::STATUS_CANCELLED
          if registration.user_id == acting_entity_id
            RegistrationsMailer.notify_organizers_of_deleted_registration(registration).deliver_later
          else
            RegistrationsMailer.notify_registrant_of_deleted_registration(registration).deliver_later
          end
        else
          raise "Unknown registration status, this should not happen"
        end
      end
    end
  end
end
