require 'gh'
require 'core_ext/hash/compact'

module Travis
  module Stash
    require 'travis/stash/services'

    class << self
      def authenticated(user)
        fail "we don't have a github token for #{user.inspect}" if user.github_oauth_token.blank?
        opts = {
          url: "#{source_protocol}://#{source_host}:#{source_port}",
          ssl: Travis.config.ssl.merge(Travis.config.stash.ssl || {}).to_hash.compact
        }

        opts[:oauth] = {
          key: config.oauth.key,
          secret: config.oauth.secret,
          access_token: user.access_token,
          access_token_secret: user.access_token_secret
        } if repository.private && config.oauth

        opts[:credentials] = config.credentials if config.credentials

        clinet = Stash::Client.new(opts)

        yield(client) if block_given?
        client
      end

      def config
        Travis.config.stash || {}
      end

    end
  end
end
