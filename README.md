# Certeurope SignAPI

## Install

## Configuration

You need to initialize CerteuropeSignAPI before using it, by writing the following to `config/initializers/certeurope_sign_api.rb`:

```ruby
CerteuropeSignAPI.init(
  base_uri:    ENV["CERTEUROPE_SIGN_API_URL"],
  pkcs12_path: File.join(Rails.root, ENV["CERTEUROPE_SIGN_API_PKCS12_PATH"],
  pkcs12_password: ENV["CERTEUROPE_SIGN_API_PKCS12_PASSWORD"]
)
```
