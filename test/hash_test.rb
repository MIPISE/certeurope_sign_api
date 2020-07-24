prepare do
  @required_keys = [:req_1, "req_2"]
  @optional_keys = [:opt_1, "opt_2", :opt_3]
end

test "Validate presence of every required hash keys" do
  hash = {req_1: nil, "req_2" => nil, opt_1: nil, "opt_2" => nil, opt_3: nil}
  assert hash.validate_keys(@required_keys, @optional_keys)
end

test "Reject hashes with missing required keys" do
  assert_raise ArgumentError do
    {req_1: nil, req_2: nil} # :req_2 instead of "req_2"
      .validate_keys(@required_keys, @optional_keys)
  end
end

test "Reject hashes with extra keys" do
  assert_raise ArgumentError do
    {req_1: nil, "req_2" => nil, extra: nil}
      .validate_keys(@required_keys, @optional_keys)
  end
end
