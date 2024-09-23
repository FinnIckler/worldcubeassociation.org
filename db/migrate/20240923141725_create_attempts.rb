# frozen_string_literal: true

class CreateAttempts < ActiveRecord::Migration[7.2]
  def change
    create_table :attempts do |t|
      t.integer :result, null: false
      t.integer :replaces
      t.references :live_result, foreign_key: { to_table: :live_results }, null: false
      t.timestamps
    end
  end
end
