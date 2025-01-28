# frozen_string_literal: true

class AddLiveResultJob < ApplicationJob
  self.queue_adapter = :shoryuken if Rails.env.production? && !EnvConfig.WCA_LIVE_SITE?
  queue_as EnvConfig.LIVE_QUEUE if Rails.env.production? && !EnvConfig.WCA_LIVE_SITE?

  # params: { results, round_id, user_id, entered_by }
  def perform(params)
    attempts = params[:results].map { |r| LiveAttempt.build(result: r) }
    round = Round.find(params[:round_id])
    event = round.event
    # TODO calculate record tag
    format = round.format
    best = attempts.select { |a| a.result > 0 }.min
    worst = attempts.max
    average = (attempts - [best] - [worst]).sum(&:result) / 3
    LiveResult.create!(registration_id: params[:registration_id],
                       round: round,
                       live_attempts: attempts,
                       entered_by: params[:entered_by],
                       best: best.result,
                       average: average)
  end
end
