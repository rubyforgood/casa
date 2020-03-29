json.extract! case_contact, :id, :user_id, :casa_case_id, :contact_type, :other_type_text, :duration_minutes, :occurred_at, :created_at, :updated_at
json.url case_contact_url(case_contact, format: :json)
