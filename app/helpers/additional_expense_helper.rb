module AdditionalExpenseHelper
  def link_to_add_fields(name, form, association)
    new_object = form.object.send(association).klass.new
    id = new_object.object_id
    fields = form.fields_for(association, new_object, child_index: id) do |builder|
      # render(association.to_s.singularize + "_fields", form: builder)
      #I think this is the key to the multiple fields, to remove the "s" of the additional_expenses and make it additional_expense like the first fields
    end
    link_to(name, "#", class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
