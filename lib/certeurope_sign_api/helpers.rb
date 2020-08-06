module CerteuropeSignAPI
  module Helpers
    def generate_uri(query = {})
      uri = parse_path
      uri += "?#{parse_query(query)}" unless query.empty?
      uri
    end

    def parse_response(response)
      {
        code: response.code.to_i,
        body: JSON.parse(response.body).underscore_hash_keys
      }
    end

    private

    def parse_path
      name
        .split("::")[1..-1]
        .join("/")
        .downcase
    end

    def parse_query(query)
      query
        .reject { |k, v| v.nil? }
        .map { |data| "#{data.shift.to_s.camelize}=#{data.shift}" }
        .join("&")
    end
  end
end
