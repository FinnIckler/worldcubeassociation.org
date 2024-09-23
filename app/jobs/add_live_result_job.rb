# frozen_string_literal: true

class AddLiveResultJob < ApplicationJob
  QUEUE_NAME = :wca_live_results

  queue_as QUEUE_NAME

  def perform(params)
    LiveResult.create(params)
  end
end
