class BaseNotification < Noticed::Base
  # Require title, url and message methods to be implemented on children
  def title
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}"
  end

  def message
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}"
  end

  def url
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}"
  end

  # Utility methods
  def read?
    record.read?
  end

  def created_at
    record.created_at
  end

  def updated_at
    record.updated_at
  end

  def created_by
    created_by_name
  end

  def muted_display
    return "" unless record.read?

    "bg-light text-muted"
  end

  private

  def created_by_name
    if params.key?(:created_by)
      params[:created_by][:display_name]
    else # keep backward compatibility with older notifications
      params[:created_by_name]
    end
  end
end
