class RemoveAllEmptyLanguages < ActiveRecord::Migration[7.0]
  def up
    safety_assured { execute "DELETE from languages WHERE name IS NULL or trim(name) = ''" }
  end
end
