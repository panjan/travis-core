require 'travis/services/base'

module Travis
  module Services
    class CancelDdtfBuild < Base
      extend Travis::Instrumentation

      register :cancel_ddtf_build

      def initialize(*)
        super

        @id = params[:id]
      end

      def run
        cancel if can_cancel?
      end
      instrument :run

      def messages
        messages = []
        messages << { :notice => 'The build was successfully cancelled.' } if can_cancel?
        messages << { :error  => 'You are not authorized to cancel this build.' } unless authorized?
        #messages << { :error  => "The build could not be cancelled." } unless build.cancelable?
        messages
      end

      def can_cancel?
        true
      end

      def cancel
        publish!
      end

      def publish!
        # TODO: I think that instead of keeping publish logic in both cancel build
        #       and cancel job services, we could call cancel_job service for each job
        #       in the matrix, which would put build in canceled state, even without calling
        #       cancel! on build explicitly. This may be a better way to handle cancelling
        #       build
        logger.info("ID >>>>>>>>>>>>>> #{@id}")
        publisher = Travis::Amqp::Publisher.new("cmd.#{@id}", { name: 'worker.commands', mandatory: true, immediate: true })
        publisher.publish({ stopped_by: 'ondrej' }.to_json)
      end

      def authorized?
        #current_user.permission?(:pull, :repository_id => build.repository_id)
        true
      end

      class Instrument < Notification::Instrument
        def run_completed
          publish(
            :msg => "Make me HAPPY!!!",
            :result => result
          )
        end
      end
      Instrument.attach_to(self)
    end
  end
end
