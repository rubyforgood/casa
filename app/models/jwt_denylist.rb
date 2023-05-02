class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = 'jwt_denylist'
end

# == Schema Information
#
# Table name: jwt_denylist
#
#  id  :bigint           not null, primary key
#  exp :datetime         not null
#  jti :string           not null
#
# Indexes
#
#  index_jwt_denylist_on_jti  (jti)
#
