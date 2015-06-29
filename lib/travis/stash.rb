require 'gh'
require 'core_ext/hash/compact'
require 'stash/client'

module Travis
  module Stash
    require 'travis/stash/services'

    class << self
      def default_opts
        opts = {
          url: "#{config.source_protocol}://#{config.source_host}:#{config.source_port}",
          ssl: Travis.config.ssl.merge(config.ssl || {}).to_hash.compact
        }

        # HACK - currently oauth library has hardcoded ssl verification if CA_FILES exists
        ::OAuth::Consumer.const_set(:CA_FILE, nil) if opts[:ssl] && opts[:ssl][:verify] == false

        opts[:credentials] = config.credentials if config.credentials
        opts
      end

      def authenticated(user)
        opts = default_opts

        if config.oauth and user
          fail "we don't have a stash token for #{user.inspect}" if user.stash_oauth_token.blank?
          opts[:oauth] = {
            key: config.oauth.key,
            secret: config.oauth.secret,
            access_token: user.stash_oauth_token,
            access_token_secret: user.stash_oauth_token_secret
          }
        end


        client = ::Stash::Client.new(opts)

        yield(client) if block_given?
        client
      end

      def client
        client = ::Stash::Client.new(default_opts)
      end

      def config
        Travis.config.stash || { }
      end

    end
  end
end
