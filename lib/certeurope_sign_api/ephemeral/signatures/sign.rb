module CerteuropeSignAPI
  module Ephemeral
    module Signatures
      module Sign
        extend Helpers

        class << self
          def create(external_order_request_id:, order_request_id:, body:, mode: "SYNC", async_post_url: "/")
            CerteuropeSignAPI::HTTPCall.post(
              generate_uri({
                async_post_url: async_post_url,
                external_order_request_id: external_order_request_id,
                mode: mode,
                order_request_id: order_request_id,
              }),
              body
            )
          end
        end
      end
    end
  end
end
