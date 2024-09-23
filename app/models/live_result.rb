# frozen_string_literal: true

class LiveResult < ApplicationRecord
  # Associations
  has_many :attempts, dependent: :destroy

  # Nested attributes for attempts
  accepts_nested_attributes_for :attempts

  after_create :notify_users
  after_update :notify_users

  belongs_to :person, class_name: 'User', foreign_key: 'person_id'

  belongs_to :entered_by, class_name: 'User', foreign_key: 'entered_by_id'

  belongs_to :round

  # Validations
  validates :best, :average, :person_id, :round_id, presence: true
  validates :best, numericality: { only_integer: true }
  validates :average, numericality: { only_integer: true }
  validates :advancing, :advancing_questionable, inclusion: { in: [true, false] }

  scope :advancing_results, -> { where(advancing: true) }
  scope :non_questionable, -> { where(advancing_questionable: false) }

  private

    def notify_users
      ActionCable.server.broadcast("results_#{round_id}}", { results: attempts.to_json })
    end
end
