require 'active_support/core_ext/hash/except'
require 'travis/support/instrumentation'
require 'travis/services/base'

module Travis
  module Services
    class UpdateDdtfBuild < Base
      extend Travis::Instrumentation

      register :update_ddtf_build

      EVENT = [:receive, :start, :error, :reset]

      def run
        if build.canceled? && event != :reset
          # build is canceled, so we ignore events other than reset
          # and we send cancel event to the worker, it may not get
          # the first one
          cancel_build_in_worker
        else
          Metriks.timer("update_ddtf_build.#{event}").time do
            build.send(:"#{event}!", data.except(:id))
          end
        end
      end
      instrument :run

      def build
        @build ||= run_service(:find_build, data)
      end

      def data
        @data ||= begin
          params[:data].symbolize_keys
        end
      end

      def event
        @event ||= EVENT.detect { |event| event == params[:event].try(:to_sym) } || raise_unknown_event
      end

      def raise_unknown_event
        raise ArgumentError, "Unknown event: #{params[:event]}, data: #{data}"
      end

      def cancel_build_in_worker
        publisher.publish({ stopped_by: current_user.try(:login) }.to_json)
      end

      def publisher
        publisher_params =
          { name: Travis.config.ddtf.command_node_queue, mandatory: true, immediate: true }
        routing_key = "#{Travis.config.ddtf.cancel_command_prefix}.#{build.id}"

        Travis::Amqp::Publisher.new(routing_key, publisher_params)
      end



      class Instrument < Notification::Instrument
        def run_completed
          publish(
            msg: "event: #{target.event} for <Build id=#{target.data[:id]}> data=#{target.data.inspect}",
            build_id: target.data[:id],
            event: target.event,
            data: target.data
          )
        end
      end
      Instrument.attach_to(self)
    end
  end
end

