# frozen_string_literal: true

class LiveAttempt < ApplicationRecord
  include Comparable
  # Associations
  belongs_to :live_result
  belongs_to :replaced_by, class_name: "LiveAttempt", optional: true

  # Validations
  validates :result, presence: true
  validates :result, numericality: { only_integer: true }
  validates :attempt_number, numericality: { only_integer: true }

  def serializable_hash(options = nil)
    { attempt_number: attempt_number, result: result }
  end

  def <=>(other)
    result <=> other.result
  end
end
