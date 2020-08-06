class Object
  def camelize_hash_keys
    case self
    when Array then map(&:camelize_hash_keys)
    when Hash
      Hash[map { |k, v|
        [k.to_s.camelize.to_sym, v.camelize_hash_keys]
      }]
    else self
    end
  end

  def underscore_hash_keys
    case self
    when Array then map(&:underscore_hash_keys)
    when Hash
      Hash[map { |k, v|
        [k.to_s.underscore.to_sym, v.underscore_hash_keys]
      }]
    else self
    end
  end
end
