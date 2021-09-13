class CreateAllCasaAdminService
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def build
    processed_params = AllCasaAdminParameters.new(@params)
      .with_password(SecureRandom.hex(10))
    @all_casa_admin = AllCasaAdmin.new(processed_params)
  end

  def create!
    @all_casa_admin.save!
    @all_casa_admin.invite!(@current_user)
  end
end
