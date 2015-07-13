require 'sidekiq-status'

module Travis
  module Services
    class FindRequest < Base
      register :find_request

      def run(options = {})
        result
      end

      def final?
        true
      end

      def updated_at
        result.updated_at if result.respond_to?(:updated_at)
      end

      private

        def result
          return @result if defined? @result
          if params[:id]
            @result = scope(:request).find_by_id(params[:id])
            return @result
          end

          if (params[:id_or_jid].to_s.size > 8)
            jid = params[:id_or_jid]
            puts "hledam jid: #{jid}"
            @result = scope(:request).find_by_jid(jid)
            puts "existujici jid: #{jid}"
            return @result if @result

            #return state form Sidekiq if scheduled
            queued_status = ::Sidekiq::Status::status(jid)
            puts "sidekiq status: #{jid}"
            @result = { state: "request_#{queued_status}", jid: jid } if queued_status
          else
            @result = scope(:request).find_by_id(params[:id_or_jid])
          end
          @result
        end
    end
  end
end
