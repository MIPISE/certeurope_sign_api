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
        body: response.body&.empty? ? nil : underscore_hash_keys(JSON.parse(response.body))
      }
    end

    def camelize(value)
      return value unless value.is_a?(String)

      value
        .split("_")
        .inject([]) { |a, p| a.push(a.empty? ? p : p.capitalize) }
        .join
    end

    def underscore(value)
      return value unless value.is_a?(String)

      value
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z])([A-Z])/, '\1_\2')
        .downcase
    end

    def camelize_hash_keys(value)
      case value
      when Array then value.map { |v| camelize_hash_keys(v) }
      when Hash
        Hash[value.map { |k, v|
          [camelize(k.to_s).to_sym, camelize_hash_keys(v)]
        }]
      else value
      end
    end

    def underscore_hash_keys(value)
      case value
      when Array then value.map { |v| underscore_hash_keys(v) }
      when Hash
        Hash[value.map { |k, v|
          [underscore(k.to_s).to_sym, underscore_hash_keys(v)]
        }]
      else value
      end
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
        .map { |data| "#{camelize(data.shift.to_s)}=#{data.shift}" }
        .join("&")
    end
  end
end
