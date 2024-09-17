# frozen_string_literal: true

class AddLiveResultJob < ApplicationJob
  QUEUE_NAME = :wca_live_results

  queue_as QUEUE_NAME

  def perform(params)
    ActionCable.server.broadcast("results_#{params[:competition_id]}_#{params[:round_id]}}", { results: params[:results].to_json })
  end
end
