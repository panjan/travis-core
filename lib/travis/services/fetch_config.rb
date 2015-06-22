require 'travis/support/logging'
require 'travis/services/base'

module Travis
  module Services
    class FetchConfig < Base
      include Logging

      register :fetch_config

      def run
        direct_payload_config = request.payload && request.payload['.travis.yml']

        if direct_payload_config
          raw_config_content = YAML.dump(direct_payload_config)
        else
          provider_service_name = "#{provider_name}_fetch_config"
          raw_config_content = run_service(provider_service_name, params)
        end

        config = retrying(3) { filter(parse(raw_config_content)) }
        config || Travis.logger.warn("[request:fetch_config] Empty config for request id=#{request.id} provider=#{provider_name}, fetch_config_params=#{fetch_config_params.inspect}")
      rescue GH::Error => e
        if e.info[:response_status] == 404
          { '.result' => 'not_found' }
        else
          { '.result' => 'server_error' }
        end
      rescue => e
        #FIXME add Stash::Error
        { '.result' => 'server_error' }
      end

      private

        def provider_name
          request.repository_provider.name
        end

        def request
          params[:request]
        end

        def fetch_config_params
          request.fetch_config_params
        end

        def parse(yaml)
          YAML.load(yaml).merge('.result' => 'configured')
        rescue StandardError, Psych::SyntaxError => e
          error "[request:fetch_config] Error parsing .travis.yml for provider=#{provider_name}, fetch_config_params=#{fetch_config_params.inspect}: #{e.message}"
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
            Travis.logger.warn("[request:fetch_config] Retrying to fetch config for #{params.inspect}") unless result
          end
          result
        end


    end
  end
end
