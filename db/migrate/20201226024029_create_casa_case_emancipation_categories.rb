class CreateCasaCaseEmancipationCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :casa_case_emancipation_categories do |t|
      t.references :casa_case, null: false, foreign_key: true
      t.references :emancipation_category, null: false, foreign_key: true, index: {name: "index_case_emancipation_categories_on_emancipation_category_id"}

      t.timestamps
    end
  end
end
