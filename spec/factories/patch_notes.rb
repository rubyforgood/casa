FactoryBot.define do
  factory :patch_note do
    sequence :note do |n|
      n.to_s
    end

    patch_note_type
    patch_note_group
  end
end
