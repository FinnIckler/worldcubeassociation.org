# frozen_string_literal: true

class LiveController < ApplicationController
  def test_admin
    @competition_id = params[:competition_id]
    @competition = Competition.find(@competition_id)
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
    @competition = Competition.find(@competition_id)
    @round = Round.find(params[:round_id])
    @event_id = @round.event.id
    @competitors = @round.registrations
  end

  def test_podiums
    @competition = Competition.find(params[:competition_id])
    @competitors = @competition.registrations.accepted
    @results = @competition.rounds.select(&:final_round?)
  end

  def test_competitors
    @competition = Competition.find(params[:competition_id])
    @competitors = @competition.registrations.accepted
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

    new_attempts = results.map.with_index(1) do |r, i|
      same_result = previous_attempts.find_by(result: r, attempt_number: i)
      if same_result.present?
        same_result
      else
        different_result = previous_attempts.find_by(attempt_number: i)
        new_result = LiveAttempt.build(result: r, attempt_number: i)
        different_result&.update(replaced_by_id: new_result.id)
        new_result
      end
    end

    # TODO: What is the best way to do this?
    r = Result.build({ value1: results[0], value2: results[1], value3: results[2], value4: results[3] || 0, value5: results[4] || 0, event_id: round.event.id, round_type_id: round.round_type_id, format_id: round.format_id })

    result.update(average: r.compute_correct_average, best: r.compute_correct_best, live_attempts: new_attempts, entered_at: Time.utc.now, entered_by: current_user)

    render json: { status: "ok" }
  end

  def round_results
    round_id = params.require(:round_id)

    render json: Round.find(round_id).live_results.includes([:live_attempts])
  end

  def open_round
    round_id = params.require(:round_id)
    competition_id = params.require(:competition_id)
    round = Round.find(round_id)

    if round.is_open?
      flash[:danger] = "Round is already open"
      return redirect_to live_schedule_admin_path(competition_id: competition_id)
    end

    unless round.round_can_be_opened?
      flash[:danger] = "You can't open this round yet"
      return redirect_to live_schedule_admin_path(competition_id: competition_id)
    end

    round.update(is_open: true)
    flash[:success] = "Successfully opened round"
    redirect_to live_schedule_admin_path(competition_id: competition_id)
  end

  def test_persons
    registration_id = params.require(:registration_id)
    registration = Registration.find(registration_id)

    @competition_id = params[:competition_id]
    @competition = Competition.find(@competition_id)

    @user = registration.user
    @results = registration.live_results.includes([:live_attempts])
  end

  def test_schedule
    @competition_id = params.require(:competition_id)
    @competition = Competition.find(@competition_id)

    @rounds = Round.joins(:competition_event).where(competition_event: { competition_id: @competition_id })
  end

  def test_schedule_admin
    @competition_id = params.require(:competition_id)
    @competition = Competition.find(@competition_id)

    @rounds = Round.joins(:competition_event).where(competition_event: { competition_id: @competition_id })
  end
end
