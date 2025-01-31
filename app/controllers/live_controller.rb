# frozen_string_literal: true

class LiveController < ApplicationController
  def test_admin
    @competition_id = params[:competition_id]
    @round = Round.find(params[:round_id])
    @event_id = @round.event.id
    round_number = @round.number
    @competitors = if round_number == 1
                     Registration.where(competition_id: @competition_id)
                                 .includes([:user])
                                 .wcif_ordered
                                 .to_enum
                                 .with_index(1)
                                 .select { |r, registrant_id| r.competing_status == 'accepted' && r.event_ids.include?(@event_id) }
                                 .map { |r, registrant_id| r.as_json({ include: [:user => { only: [:name], methods: [], include: []}]}).merge("registration_id" => registrant_id) }
                   else
                     previous_round = Round.joins(:competition_event).find_by(competition_event: { competition_id: @competition_id, event_id: @event_id }, number: round_number - 1)
                     advancing = previous_round.live_results.where(advancing: true).pluck(:registration_id)
                     Registration.where(competition_id: @competition_id)
                                 .includes([:user])
                                 .wcif_ordered
                                 .to_enum
                                 .with_index(1)
                                 .select { |r, registrant_id| advancing.include?(r.id) }
                                 .map { |r, registrant_id| r.as_json({ include: [:user => { only: [:name], methods: [], include: []}]}).merge("registration_id" => registrant_id) }
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
                     previous_round = Round.joins(:competition_event).find_by(competition_event: { competition_id: @competition_id, event_id: @event_id }, number: round_number - 1)
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
    round = Round.find(params.require(:round_id))
    registration_id = params.require(:registration_id)

    result = LiveResult.includes(:live_attempts).find_by(round: round, registration_id: registration_id)

    unless result.present?
      return render json: { status: "result does not exist" }, status: :unprocessable_entity
    end

    previous_attempts = result.live_attempts

    attempts = results.map.with_index do |r, i|
      # TODO: This currently destroys the replaced results
      previous_attempts.find_by(result: r) ||
        (previous_attempts[i] ? LiveAttempt.build(result: r, replaces: previous_attempts[i].id) : LiveAttempt.build(result: r))
    end

    # TODO: What is the best way to do this?
    r = Result.build({ value1: results[0], value2: results[1], value3: results[2], value4: results[3], value5: results[4], event_id: round.event.id, round_type_id: round.round_type_id, format_id: round.format_id })

    result.update(live_attempts: attempts, average: r.compute_correct_average, best: r.compute_correct_best)

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

  def test_schedule
    @competition_id = params.require(:competition_id)
    @competition = Competition.find(@competition_id)

    @rounds = Round.joins(:competition_event).where(competition_event: { competition_id: @competition_id })

  end
end
