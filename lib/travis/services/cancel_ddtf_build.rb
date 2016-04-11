require 'travis/services/base'

module Travis
  module Services
    class CancelDdtfBuild < Base
      extend Travis::Instrumentation

      register :cancel_ddtf_build
      attr_reader :id

      def initialize(*)
        super
      end

      def run
        cancel if can_cancel?
      end
      instrument :run

      def messages
        messages = []
        messages << { :notice => 'The build was successfully cancelled.' }
        messages << { :error  => 'You are not authorized to cancel this build.' } unless authorized?
        messages << { :error  => "The build could not be cancelled." } unless build.cancelable?
        messages << { :error  => 'Build not found.' } unless build
        messages
      end

      def cancel
        # build may have been retrieved with a :join query, so we need to reset the readonly status
        build.send(:instance_variable_set, :@readonly, false)
        build.cancel!

        # Here we want to set :canceled state even if matrix is empty
        unless build.canceled?
          build.state = :canceled
          build.save!
        end

        publish!
      end

      def publish!
        publisher.publish(stopped_by: current_user.login)
      end

      def publisher
        publisher_params =
          { name: Travis.config.ddtf.command_node_queue, mandatory: true, immediate: true }
        routing_key = "#{Travis.config.ddtf.cancel_command_prefix}.#{build.id}"

        Travis::Amqp::Publisher.new(routing_key, publisher_params)
      end

      def can_cancel?
        authorized? && build.cancelable?
      end

      def authorized?
        true
      end

      def build
        @build ||= run_service(:find_build, params)
      end

      class Instrument < Notification::Instrument
        def run_completed
          publish(
            :msg => "for <Build id=#{target.id}> (#{target.current_user.login})",
            :result => result
          )
        end
      end
      Instrument.attach_to(self)
    end
  end
end
