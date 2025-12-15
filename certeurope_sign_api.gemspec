Gem::Specification.new do |s|
  s.name = "certeurope_sign_api"
  s.version = "1.1.0"
  s.summary = "Gem for Certeurope SignAPI"
  s.description = "Gem for Certeurope SignAPI"
  s.author = "Guillaume BOUDON"
  s.email = "guillaumeboudon@gmail.com"
  s.homepage = "https://github.com/mipise/certeurope_sign_api"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")

  s.add_development_dependency "cutest", "~> 1.2"
  s.add_development_dependency "dotenv", "~> 3.2"
end
