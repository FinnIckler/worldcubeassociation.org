# frozen_string_literal: true

class LiveController < ApplicationController
  def test_admin
    @competition_id = params[:competition_id]
    @round = Round.find(params[:round_id])
    @event_id = @round.event.id
    round_number = @round.number
    @competitors = if round_number == 1
                     Registration.joins(:registration_competition_events)
                                 .where(
                                   competing_status: 'accepted',
                                   competition_id: @competition_id,
                                   registration_competition_events: { competition_event_id: @round.competition_event_id }
                                 ).includes([:user])
                   else
                     previous_round = Round.find_by(competition_id: @competition_id, event_id: @event_id, number: round_number - 1)
                     previous_round.live_results.where(advancing: true).includes(:registration).map(&:registration)
                   end
  end

  def test_results
    @competition_id = params[:competition_id]
    @round = Round.find(params[:round_id])
    @event_id = @round.event.id
    round_number = @round.number
    @competitors = if round_number == 1
                     Registration.joins(:registration_competition_events)
                                 .where(
                                   competition_id: @competition_id,
                                   competing_status: 'accepted',
                                   registration_competition_events: { competition_event_id: @round.competition_event_id }
                                 ).includes([:user])
                   else
                     previous_round = Round.find_by(competition_id: @competition_id, event_id: @event_id, number: round_number - 1)
                     previous_round.live_results.where(advancing: true).includes(:registration).map(&:registration)
                   end
  end

  def add_result
    results = params.require(:attempts)
    round_id = params.require(:round_id)
    registration_id = params.require(:registration_id)

    if LiveResult.exists?(round_id: round_id, registration_id: registration_id)
      return render json: { status: "result already exist" }, status: :unprocessable_entity
    end

    AddLiveResultJob.perform_now({ results: results,
                                   round_id: round_id,
                                   registration_id: registration_id,
                                   entered_by: current_user })

    render json: { status: "ok" }
  end

  def update_result
    results = params.require(:attempts)
    round_id = params.require(:round_id)
    registration_id = params.require(:registration_id)

    result = LiveResult.includes(:live_attempts).find_by(round_id: round_id, registration_id: registration_id)

    unless result.present?
      return render json: { status: "result does not exist" }, status: :unprocessable_entity
    end

    previous_attempts = result.live_attempts

    attempts = results.map.with_index do |r, i|
      previous_attempt = previous_attempts.find_by(result: r)
      next previous_attempt if previous_attempt.present?

      replaces = previous_attempts[i]
      next LiveAttempt.build(result: r, replaces: replaces.id) if replaces.present?

      LiveAttempt.build(result: r)
    end

    result.update(live_attempts: attempts)

    render json: { status: "ok" }
  end

  def get_round_results
    round_id = params.require(:round_id)

    render json: Round.find(round_id).live_results.includes([:live_attempts])
  end

  def test_persons
    registration_id = params.require(:registration_id)
    registration = Registration.find(registration_id)

    @competition_id = params[:competition_id]
    @user = registration.user
    @results = registration.live_results.includes([:live_attempts])
  end
end
