Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.formatter = Class.new do |fmt|
    def fmt.call(data)
      { msg: 'Request', request: data }
    end
  end
end
