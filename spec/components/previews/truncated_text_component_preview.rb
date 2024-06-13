class TruncatedTextComponentPreview < ViewComponent::Preview
  def default
    render(TruncatedTextComponent.new(
      Faker::Lorem.paragraph(sentence_count: 3),
      label: "Some Label"
    ))
  end
end
