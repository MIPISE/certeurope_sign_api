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
  pkcs12_password: ENV["CERTEUROPE_SIGN_API_PKCS12_PASSWORD"],
)
```

You can specify default pdf signature options, in order to define default options of the signature's template image to use for signing the pdf document :

```ruby
CerteuropeSignAPI.set_default_pdf_signature_options(
  {
    width: 250, # signature's template's image width (px)
    height: 40, # signature's template's image height (px)
    x: 50, # default x position (px) of the signature in a document
    y: 200, # default y position (px) of the signature in a document
    image_path: "path to signature template image",
    # Options when adding lines of text on the signature's template's image
    # (like date and signatory's name) 
    lines_default_options: 
      {
        line_color: 0, # default color
        line_font_size: 8, # default font size
        line_font: "Times_roman", # default font
        line_pos_x_in_image: 45 # # default x position (px) in the image
      }
  }
)
```
 
The signature_pdf_options in the Certeurope signature request can be left empty, but if so the document returned by Certeurope after the signature succeeds won't have any visible evidence of the signature. 

## Tests

1. Install dependencies using the [dep](https://github.com/djanowski/dep/) command `dep install`.
2. Since it is mandatory for tests to connect to a sandbox Certeurope SignAPI, we need to include your certificate:
    - append your certificate to `test/support/certificate.p12`
    - append a .env file to `test/support/.env`. It should be based on `env.template` from the same directory
3. Then execute test with a single `make`
