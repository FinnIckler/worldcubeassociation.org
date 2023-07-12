# frozen_string_literal: true

class Api::V10::ApiController < ApplicationController
  def jwt
    unless current_user
      return render status: :unauthorized, json: { error: "Please log in" }
    end

    render json: { status: "ok" }
  end
end
