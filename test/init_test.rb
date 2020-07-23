test "CerteuropeSignAPI does not include :base_uri by default" do
  assert_equal CerteuropeSignAPI.base_uri, nil
end

test "CerteuropeSignAPI embark API base uri after init" do
  init_certeurope_sign_api
  assert_equal CerteuropeSignAPI.base_uri, ENV["CERTEUROPE_SIGN_API_URL"]
  assert_equal CerteuropeSignAPI.certificate.class, OpenSSL::X509::Certificate
  assert_equal CerteuropeSignAPI.key.class, OpenSSL::PKey::RSA
end
