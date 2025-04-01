class RemoveDuplicateIndexindexEmancipationOptionsOnEmancipationCategoryId < ActiveRecord::Migration[7.2]
  def change
    remove_index :emancipation_options, :emancipation_category_id
  end
end
