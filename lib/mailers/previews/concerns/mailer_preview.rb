module MailerPreview
  private

  def preview_linkable(record)
    @id ||= 1
    record.tap do |r|
      r.id = @id
      @id += 1
      def r.persisted?
        true
      end
    end
  end
end
