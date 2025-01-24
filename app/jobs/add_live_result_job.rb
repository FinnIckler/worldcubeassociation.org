# frozen_string_literal: true

class AddLiveResultJob < ApplicationJob
  self.queue_adapter = :shoryuken if Rails.env.production? && !EnvConfig.WCA_LIVE_SITE?
  queue_as EnvConfig.LIVE_QUEUE if Rails.env.production? && !EnvConfig.WCA_LIVE_SITE?

  # params: { results, round_id, user_id, entered_by }
  def perform(params)
    attempts = params[:results].map { |r| LiveAttempt.build(result: r) }
    LiveResult.create!(round_id: params[:round_id],
                       person_id: params[:user_id],
                       live_attempts: attempts,
                       entered_by: params[:entered_by])
  end
end
