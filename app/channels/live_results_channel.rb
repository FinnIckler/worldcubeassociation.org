# frozen_string_literal: true

class LiveResultsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "results_#{params[:competition_id]}_#{params[:round_id]}}"
  end
end
