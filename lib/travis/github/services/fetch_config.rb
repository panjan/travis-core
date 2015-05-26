require 'gh'
require 'yaml'
require 'active_support/core_ext/class/attribute'
require 'travis/support/logging'
require 'travis/support/instrumentation'
require 'travis/services/base'

module Travis
  module Github
    module Services
      # encapsulates fetching a .travis.yml from a given commit's config_url
      class FetchConfig < Travis::Services::Base
        include Logging
        extend Instrumentation

        register :github_fetch_config

        def run
          fetch || Travis.logger.warn("[request:fetch_config] Empty config for request id=#{request.id} config_url=#{config_url.inspect}")
        end
        instrument :run

        def request
          params[:request]
        end

        def fetch_config_params
          request.fetch_config_params
        end

        def config_url
          GH.full_url("repos/#{fetch_config_params[:project_key]}/#{fetch_config_params[:repository_name]}/contents/#{fetch_config_params[:path]}?ref=#{fetch_config_params[:ref]}").to_s
        end

        private

          def fetch
            #TODO: does ti work even for private repos?
            # e.g.: gh = Github.authenticate(current_user)
            content = GH[config_url]['content']
            Travis.logger.warn("[request:fetch_config] Empty content for #{config_url}") if content.nil?
            content = content.to_s.unpack('m').first
            Travis.logger.warn("[request:fetch_config] Empty unpacked content for #{config_url}, content was #{content.inspect}") if content.nil?
            nbsp = "\xC2\xA0".force_encoding("binary")
            content = content.gsub(/^(#{nbsp})+/) { |match| match.gsub(nbsp, " ") }

            content
          end

          class Instrument < Notification::Instrument
            def run_completed
              # TODO exctract something like Url.strip_secrets
              config_url = target.config_url.gsub(/(token|secret)=\w*/) { "#{$1}=[secure]" }
              publish(msg: "#{config_url}", url: config_url, result: result)
            end
          end
          Instrument.attach_to(self)
      end
    end
  end
end
