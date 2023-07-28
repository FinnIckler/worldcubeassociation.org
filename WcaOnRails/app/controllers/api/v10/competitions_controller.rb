class Api::V10::CompetitionsController < Api::V10::ApiController
  def show
    competition = Competition.find(params[:competition_id])
    if stale?(competition, public: true)
      render json: competition
    end
  end

  def schedule
    competition = Competition.find(params[:competition_id])
    if stale?(competition, public: true)
      render json: competition.schedule_wcif
    end
  end
end
