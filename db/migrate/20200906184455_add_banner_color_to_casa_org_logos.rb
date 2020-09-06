class AddBannerColorToCasaOrgLogos < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_org_logos, :banner_color, :string
  end
end
