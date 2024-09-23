# frozen_string_literal: true

class CreateLiveResults < ActiveRecord::Migration[7.2]
  def change
    create_table :live_results do |t|
      t.integer :ranking
      t.integer :best, null: false
      t.integer :average, null: false
      t.string :single_record_tag, limit: 255
      t.string :average_record_tag, limit: 255
      t.boolean :advancing, default: false, null: false
      t.integer :person_id, null: false
      t.integer :round_id, null: false
      t.integer :entered_by_id, null: false
      t.boolean :advancing_questionable, default: false, null: false
      t.timestamps
    end
  end
end
