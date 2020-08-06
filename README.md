# Certeurope SignAPI

## Install

Add the gem to your dependencies. Example with bundler, append the gem to your Gemfile:

```ruby
gem "certeurope_sign_api", github: "mipise/certeurope_sign_api", tag: "0.0.0"
```

## Configuration

:warning: This configuration is meant for a Ruby on Rails application. Otherwise, you will need to adapt it to your needs.

You need to initialize CerteuropeSignAPI before using it, by writing the following to `config/initializers/certeurope_sign_api.rb`:

```ruby
CerteuropeSignAPI.init(
  base_uri:    ENV["CERTEUROPE_SIGN_API_URL"],
  pkcs12_path: File.join(Rails.root, ENV["CERTEUROPE_SIGN_API_PKCS12_PATH"]),
  pkcs12_password: ENV["CERTEUROPE_SIGN_API_PKCS12_PASSWORD"]
)
```

## Tests

1. Install dependencies using the [dep](https://github.com/djanowski/dep/) command `dep install`.
2. Since it is mandatory for tests to connect to a sandbox Certeurope SignAPI, we need to include your certificate:
    - append your certificate to `test/support/certificate.p12`
    - append a .env file to `test/support/.env`. It should be based on `env.template` from the same directory
3. Then execute test with a single `make`
