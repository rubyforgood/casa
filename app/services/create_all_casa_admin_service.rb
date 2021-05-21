class CreateAllCasaAdminService
  def initialize(params)
    @params = params
  end

  def build
    processed_params = AllCasaAdminParameters.new(@params)
      .with_password(SecureRandom.hex(10))
    @all_casa_admin = AllCasaAdmin.new(processed_params)
  end

  def create!
    @all_casa_admin.save!
    @all_casa_admin.invite!
  end
end
