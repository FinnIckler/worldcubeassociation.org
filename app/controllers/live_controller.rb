# frozen_string_literal: true

class LiveController < ApplicationController
  protect_from_forgery except: [:notify]
  def add
    results = params.require(:results).permit(:attempt1, :attempt2, :attempt3, :attempt4, :attempt5)
    competition_id = params.require(:competition_id)
    round_id = params.require(:round_id)
    AddLiveResultJob.perform_later({ results: results, competition_id: competition_id, round_id: round_id })

    render json: { status: "ok" }
  end

  def show
    @competition_id = params.require(:competition_id)
    @round_id = params.require(:round_id)
  end

  def admin
    @competition_id = params.require(:competition_id)
    @round_id = params.require(:round_id)
  end
end
