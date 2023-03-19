class BaseNotification < Noticed::Base
  private

  def created_by_name
    if params.key?(:created_by)
      params[:created_by][:display_name]
    else # keep backward compatibility with older notifications
      params[:created_by_name]
    end
  end
end
