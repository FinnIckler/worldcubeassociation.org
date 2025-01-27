# frozen_string_literal: true

class AddLiveResultJob < ApplicationJob
  self.queue_adapter = :shoryuken if Rails.env.production? && !EnvConfig.WCA_LIVE_SITE?
  queue_as EnvConfig.LIVE_QUEUE if Rails.env.production? && !EnvConfig.WCA_LIVE_SITE?

  # params: { results, round_id, user_id, entered_by }
  def perform(params)
    attempts = params[:results].map { |r| LiveAttempt.build(result: r) }
    round = Round.find(params[:round_id]).includes([:event, :format])
    event = round.event
    # TODO calculate record tag
    format = round.format
    best = min(attempts.select { |a| a > 0 })
    worst = max(attempts)
    LiveResult.create!(registration_id: params[:registration_id],
                       live_attempts: attempts,
                       entered_by: params[:entered_by],
                       best: best,
                       average: (attempts - best - worst) / format.expected_solve_count)
  end
end
