# frozen_string_literal: true

class AddLiveResultJob < ApplicationJob
  QUEUE_NAME = :wca_live_results

  queue_as QUEUE_NAME

  def perform(params)
    # Simulating SNS Notification by calling ourselves
    client.post("/live/notify") do |request|
      request.body = { results: params[:results].to_json, competition_id: params[:competition_id], round_id: params[:round_id] }
    end
  end

  private

  def url
    if Rails.env.local?
      "http://wca_on_rails:3000"
    else
      EnvConfig.ROOT_URL
    end
  end

  def client
    Faraday.new(
      url: url,
      &FaradayConfig
    )
  end
end
