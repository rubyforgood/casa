class ReplaceContactTypeWithContactTypesOnCaseContact < ActiveRecord::Migration[6.0]
  def change
    # NOTE: This is a destructive migration that we would normally avoid
    #       if we were working on production data, but because there is
    #       no production data we are comfortable being destructive and
    #       losting whatever data is in the `contact_type` column.
    remove_column :case_contacts, :contact_type, :string
    add_column :case_contacts, :contact_types, :string, array: true
    # By default, indexes in postgresql are full-value indexes.
    # However, when you have fields that hold multiple values, such as enums
    # or jsonb, you want to rely on a full-text search index type.
    # gin indexes are a full-text index type that works well in this context.
    # You can read more at the official PostgreSQL docs:
    # https://www.postgresql.org/docs/current/textsearch-indexes.html
    add_index :case_contacts, :contact_types, using: :gin
  end
end
