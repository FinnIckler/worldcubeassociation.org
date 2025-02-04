# frozen_string_literal: true

class AddEnteredAt < ActiveRecord::Migration[7.2]
  def change
    add_column :live_results, :entered_at, :datetime, default: Time.now, null: false
    LiveResult.all.map { |l| l.update entered_at: l.created_at }
  end
end
