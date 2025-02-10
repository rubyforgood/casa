# Allows rails generators (scaffold/controller) to use custom policy generator.
# Arguments for rails generators will be passed to the policy generator.
# Options will be shown in the help text for the rails generators,
# including the option to skip the policy generator (--skip-policy).
module PolicyGenerator
  module ControllerGenerator
    extend ActiveSupport::Concern

    included do
      hook_for :policy, in: nil, default: true, type: :boolean do |generator|
        # use actions from controller invocation
        invoke generator, [name.singularize, *actions]
      end
    end
  end

  module ScaffoldControllerGenerator
    extend ActiveSupport::Concern

    included do
      hook_for :policy, in: nil, default: true, type: :boolean do |generator|
        # prevent attribute arguments (name:string) being confused with actions
        scaffold_actions = %w[index new create show edit update destroy]
        invoke generator, [name.singularize, *scaffold_actions]
      end
    end
  end
end

module ActiveModel
  class Railtie < Rails::Railtie
    generators do |app|
      Rails::Generators.configure! app.config.generators
      Rails::Generators::ControllerGenerator.include PolicyGenerator::ControllerGenerator
      Rails::Generators::ScaffoldControllerGenerator.include PolicyGenerator::ScaffoldControllerGenerator
    end
  end
end
