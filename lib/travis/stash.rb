require 'gh'
require 'core_ext/hash/compact'
require 'stash/client'

module Travis
  module Stash
    require 'travis/stash/services'

    class << self
      def authenticated(user)
        fail "we don't have a stash token for #{user.inspect}" if user.stash_oauth_token.blank?
        opts = {
          url: "#{config.source_protocol}://#{config.source_host}:#{config.source_port}",
          ssl: Travis.config.ssl.merge(Travis.config.stash.connection.ssl || {}).to_hash.compact
        }

        opts[:oauth] = {
          key: config.oauth.key,
          secret: config.oauth.secret,
          access_token: user.stash_oauth_token,
          access_token_secret: user.stash_oauth_token_secret
        } if config.oauth and user

        opts[:credentials] = config.credentials if config.credentials


        # HACK - currently oauth library has hardcoded ssl verification if CA_FILES exists
        ::OAuth::Consumer.const_set(:CA_FILE, nil) if opts[:ssl] && opts[:ssl][:verify] == false

        client = ::Stash::Client.new(opts)

        yield(client) if block_given?
        client
      end

      def config
        Travis.config.stash || {}
      end

    end
  end
end
