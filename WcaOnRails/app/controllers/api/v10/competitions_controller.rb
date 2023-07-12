class Api::V10::CompetitionsController < Api::V10::ApiController
  def show
    competition = Competition.find(params[:competition_id])
    render json: competition
  end
end
