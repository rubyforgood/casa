Dir[File.join(Rails.root, "lib", "core_extensions", "*.rb")].each { |f| require f }
