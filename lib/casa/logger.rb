require 'ougai'

module Casa
  class Logger < Ougai::Logger
    include ActiveSupport::LoggerThreadSafeLevel
    include ActiveSupport::LoggerSilence

    def initialize(*args)
      super
      after_initialize if respond_to?(:after_initialize) && ActiveSupport::VERSION::MAJOR < 6
    end

    def create_formatter
      if Rails.env.development? || Rails.env.test?
        Ougai::Formatters::Readable.new
      else
        Ougai::Formatters::Bunyan.new
      end
    end
  end
end
