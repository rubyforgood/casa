class AllCasaAdminParameters < SimpleDelegator
  def initialize(params)
    params =
      params.require(:all_casa_admin).permit(:email, :password)

    super
  end

  def with_password(password)
    params[:password] = password
    self
  end

  private

  def params
    __getobj__
  end
end
