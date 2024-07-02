# frozen_string_literal: true

# Migration file to create custom_links table
class CreateCustomLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :custom_links do |t|
      t.string :text
      t.text :url
      t.references :casa_org, null: false, foreign_key: true
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
