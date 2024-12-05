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
  delegate :read?, to: :record

  delegate :created_at, to: :record

  delegate :updated_at, to: :record

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
