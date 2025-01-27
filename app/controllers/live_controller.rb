# frozen_string_literal: true

class LiveController < ApplicationController
  def test_admin
    @competition = Competition.find(params[:competition_id])
    @round_id = params[:round_id]
    @event_id = Round.find(@round_id).event.id
  end

  def test_results
    @competition = Competition.find(params[:competition_id])
    @round_id = params[:round_id]
    @event_id = Round.find(@round_id).event.id
  end

  def add_result
    results = params.require(:attempts)
    round_id = params.require(:round_id)
    registration_id = params.require(:registration_id)
    AddLiveResultJob.perform_now({ results: results,
                                   round_id: round_id,
                                   registration_id: registration_id,
                                   entered_by: current_user })

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
