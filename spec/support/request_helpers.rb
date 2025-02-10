module Support
  module RequestHelpers
    def response_json
      @response_json ||= JSON.parse(response.body, symbolize_names: true)
    end
  end
end
