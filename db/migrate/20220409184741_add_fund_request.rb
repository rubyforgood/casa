class AddFundRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :casa_orgs, :show_fund_request, :boolean, default: false
  end
end
