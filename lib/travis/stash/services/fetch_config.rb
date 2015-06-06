require 'gh'
require 'yaml'
require 'active_support/core_ext/class/attribute'
require 'travis/support/logging'
require 'travis/support/instrumentation'
require 'travis/services/base'

module Travis
  module Stash
    module Services
      # encapsulates fetching a .travis.yml from a given commit's fetch_config_params
      class FetchConfig < Travis::Services::Base
        include Logging
        extend Instrumentation

        register :stash_fetch_config

        def run
          fetch || Travis.logger.warn("[request:fetch_config] Empty config for request id=#{request.id} fetch_config_params=#{fetch_config_params.inspect}")
        end
        instrument :run

        def request
          params[:request]
        end

        def fetch_config_params
          request.fetch_config_params
        end

        private

          def fetch
            Stash.authenticated(current_user).content(fetch_config_params)
          end

          class Instrument < Notification::Instrument
            def run_completed
              # TODO exctract something like Url.strip_secrets
              fetch_config_params = target.fetch_config_params.inspect.gsub(/(token|secret)=\w*/) { "#{$1}=[secure]" }
              publish(msg: "#{fetch_config_params}", fetch_config_params: fetch_config_params, result: result)
            end
          end
          Instrument.attach_to(self)
      end
    end
  end
end
