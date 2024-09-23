# frozen_string_literal: true

class Attempt < ApplicationRecord
  # Associations
  belongs_to :live_result

  # Validations
  validates :result, presence: true
  validates :result, numericality: { only_integer: true }
end
