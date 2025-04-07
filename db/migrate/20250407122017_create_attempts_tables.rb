# frozen_string_literal: true

class CreateLiveResultTables < ActiveRecord::Migration[7.2]
  def change
    create_table :attempts do |t|
      t.integer :value, null: false
      t.integer :attempt_number, null: false
      t.references :result, null: false
      t.timestamps
    end
  end
end
