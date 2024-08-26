class CanAccessFlipperUI
  def self.matches?(request)
    session = request.env["warden"].raw_session.to_h
    session["warden.user.all_casa_admin.session"].present?
  end
end
