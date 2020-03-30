class CaseContactParameters < SimpleDelegator
  def initialize(params)
    params = params
      .require(:case_contact)
      .permit(:contact_type, :other_type_text, :duration_minutes, :occurred_at)

    super(params)
  end

  def with_creator(creator)
    params[:creator] = creator
    self
  end

  def with_casa_case(casa_case)
    params[:casa_case] = casa_case
    self
  end

  private

  def params
    __getobj__
  end
end
