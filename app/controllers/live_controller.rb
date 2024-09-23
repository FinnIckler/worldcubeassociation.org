# frozen_string_literal: true

class LiveController < ApplicationController
  def add
    results = params.require(:results).permit(:attempt1, :attempt2, :attempt3, :attempt4, :attempt5)
    round_id = params.require(:round_id)
    live_result_params = {
      best: 10,
      average: 9,
      advancing: false,
      advancing_questionable: false,
      person_id: 15_073,
      entered_by: 15_073,
      round_id: round_id,
      attempts_attributes: [
        { result: results[:attempt1], replaces: nil },
        { result: results[:attempt2], replaces: nil },
        { result: results[:attempt3], replaces: nil },
        { result: results[:attempt4], replaces: nil },
        { result: results[:attempt5], replaces: nil },
      ],
    }
    AddLiveResultJob.perform_later(live_result_params)

    render json: { status: "ok" }
  end

  def show
    @round_id = params.require(:round_id)
  end

  def admin
    @round_id = params.require(:round_id)
  end
end
