class Hash
  def validate_keys(required = [], optional = [])
    ensure_required_keys(required)
    prevent_extra_keys(required + optional)
  end

  private

  def ensure_required_keys(required_keys)
    return true unless (missing_keys = required_keys - keys).any?

    raise(ArgumentError, "Required keys not found: #{missing_keys}")
  end

  def prevent_extra_keys(accepted_keys)
    return true unless (missing_keys = keys - accepted_keys).any?

    raise(ArgumentError, "Keys not accepted: #{missing_keys}")
  end
end
