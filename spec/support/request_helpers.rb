require 'ostruct'

module Request
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end

    def rubify
      JSON.parse(response.body, object_class: OpenStruct)
    end
  end
end
