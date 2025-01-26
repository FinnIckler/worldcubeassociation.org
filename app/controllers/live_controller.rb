# frozen_string_literal: true

class LiveController < ApplicationController
  def test_admin
    @competition_id = params[:competition_id]
    @round_id = params[:round_id]
    @event_id = Round.find(@round_id).event.id
  end

  def test_results
    @competition_id = params[:competition_id]
    @round_id = params[:round_id]
    @event_id = Round.find(@round_id).event.id
  end

  def add_result
    results = params.require(:attempts)
    round_id = params.require(:round_id)
    user_id = params.require(:user_id)
    AddLiveResultJob.perform_now({ results: results,
                                   round_id: round_id,
                                   user_id: user_id,
                                   entered_by: current_user })

    render json: { status: "ok" }
  end

  def get_round_results
    round_id = params.require(:round_id)

    render json: Round.find(round_id).live_results.includes([:live_attempts])
  end
end
