class Hash
  def assert_required_keys(*required_keys)
    missing_keys = [required_keys].flatten - keys
    raise(ArgumentError, "Missing required key(s): #{missing_keys.join(", ")}") unless missing_keys.empty?
  end  
end
