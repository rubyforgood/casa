class BaseNotifier < Noticed::Event
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

  # Whether this notification can still be rendered. Override in notifiers whose target record may
  # have been deleted (a stale GlobalID resolves to nil) -- orphaned notifications are hidden from the
  # index + unread badge instead of rendering an empty, contextless item.
  def renderable?
    true
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

  private

  def created_by_name
    if params.key?(:created_by)
      params[:created_by].display_name
    else # keep backward compatibility with older notifications
      params[:created_by_name]
    end
  end
end
