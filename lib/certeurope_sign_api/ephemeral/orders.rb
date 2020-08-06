module CerteuropeSignAPI
  module Ephemeral
    module Orders
      extend Helpers

      class << self
        def create(body:)
          CerteuropeSignAPI::HTTPCall.post(generate_uri, body)
        end
      end
    end
  end
end
