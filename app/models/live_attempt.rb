# frozen_string_literal: true

class LiveAttempt < ApplicationRecord
  include Comparable
  # Associations
  belongs_to :live_result

  # Validations
  validates :result, presence: true
  validates :result, numericality: { only_integer: true }

  def serializable_hash(options = nil)
    result
  end

  def <=>(other)
    result <=> other.result
  end
end
