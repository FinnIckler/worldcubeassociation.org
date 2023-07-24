class Api::V10::CompetitionsController < Api::V10::ApiController
  def show
    competition = Competition.find(params[:competition_id])
    render json: competition
  end

  def schedule
    competition = Competition.find(params[:competition_id])
    render json: competition.schedule_wcif
  end
end
