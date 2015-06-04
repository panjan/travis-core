require 'gh'
require 'yaml'
require 'active_support/core_ext/class/attribute'
require 'travis/support/logging'
require 'travis/support/instrumentation'
require 'travis/services/base'

module Travis
  module Stash
    module Services
      # encapsulates fetching a .travis.yml from a given commit's config_url
      class FetchConfig < Travis::Services::Base
        include Logging
        extend Instrumentation

        register :stash_fetch_config

        def run
          config = retrying(3) { filter(parse(fetch)) }
          config || Travis.logger.warn("[request:fetch_config] Empty config for request id=#{request.id} config_url=#{config_url.inspect}")
        rescue GH::Error => e
          if e.info[:response_status] == 404
            { '.result' => 'not_found' }
          else
            { '.result' => 'server_error' }
          end
        end
        instrument :run

        def request
          params[:request]
        end

        def fetch_config_params
          params[:fetch_config_params]
        end

        private

        def fetch
          direct_payload_config = request.payload && request.payload['.travis.yml']
          direct_payload_config || Stash.authenticated(current_user).content(fetch_config_params)
        end

          def parse(yaml)
            YAML.load(yaml).merge('.result' => 'configured')
          rescue StandardError, Psych::SyntaxError => e
            error "[request:fetch_config] Error parsing .travis.yml for #{fetch_config_params}: #{e.message}"
            {
              '.result' => 'parse_error',
              '.result_message' => e.is_a?(Psych::SyntaxError) ? e.message.split(": ").last : e.message
            }
          end

          def filter(config)
            unless Travis::Features.active?(:template_selection, request.repository)
              config = config.except('dist').except('group')
            end

            config
          end

          def retrying(times)
            count, result = 0, nil
            until result || count > times
              result = yield
              count += 1
              Travis.logger.warn("[request:fetch_config] Retrying to fetch config for #{fetch_config_params}") unless result
            end
            result
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
