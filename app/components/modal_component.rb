# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  renders_one :open_button
  renders_one :modal_header
  renders_one :modal_content
  renders_one :modal_footer

  def initialize(button: true, modal: true, button_value: nil, header_text: nil, body_text: nil, id: Digest::UUID.uuid_v4)
    @has_button = button
    @has_modal = modal
    @button_value = button_value
    @header_text = header_text
    @body_text = body_text
    @id = id
  end
end
