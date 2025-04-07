# frozen_string_literal: true

class TemporaryAttempt < ApplicationRecord
  include Comparable

  default_scope { order(:attempt_number) }

  belongs_to :result

  validates :value, presence: true
  validates :value, numericality: { only_integer: true }
  validates :attempt_number, numericality: { only_integer: true }

  def <=>(other)
    value <=> other.value
  end
end
