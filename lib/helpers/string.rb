class String
  def camelize
    split("_")
      .inject([]) { |a, p| a.push(a.empty? ? p : p.capitalize) }
      .join
  end

  def underscore
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z])([A-Z])/, '\1_\2')
      .downcase
  end
end
