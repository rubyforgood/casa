module PolicyHelper # rubocop:todo Style/Documentation
  def is_casa_admin_of_org?(user, record)
    user.is_instance?(CasaAdmin) && (record.casa_org == user.casa_org)
  end
end
