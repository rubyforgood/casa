class VolunteerParameters < UserParameters
  def initialize(params)
    super(params, :volunteer)
  end
end
