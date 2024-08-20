# NOTE: Rails namespace in order to be able to called from rails generators (see initializers/generators.rb)
class Rails::PolicyGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  remove_class_option :skip_namespace
  remove_class_option :skip_collision_check

  argument :actions, type: :array, banner: "action action",
    default: %w[index new show create edit update destroy]
  class_option :headless, type: :boolean, default: false,
    desc: "Policy for non-model routes (dashboard, collection, etc)"

  def create_policy
    template "policy.rb", File.join("app/policies", class_path, "#{file_name}_policy.rb")
  end

  def create_policy_spec
    template "policy_spec.rb", File.join("spec/policies", class_path, "#{file_name}_policy_spec.rb")
  end
end
