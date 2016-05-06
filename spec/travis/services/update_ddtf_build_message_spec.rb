require 'spec_helper'

describe Travis::Services::UpdateDdtfBuildMessage do
  include Support::ActiveRecord

  let(:service) { described_class.new(event: event, data: payload) }
  let(:payload) { WORKER_PAYLOADS["build:test:#{event}"].merge('id' => build.id) }
  let(:build)   { Factory(:build, state: :created, started_at: nil, finished_at: nil ) }

  before :each do
    build.matrix.delete_all
  end

  describe 'event: message' do
    let(:event) { :message }

    it 'appends message to build' do
      service.run
      build.reload.message.should_not nil
    end

    it 'appends whole message to build' do
      service.run
      res = JSON.parse(build.reload.message)
      res.first.symbolize_keys.should include(:position,:message,:timestamp)
    end

    context 'whem some message is present' do
      let(:message_in_db) do
        { position: '0', timestamp: '2011-01-01 00:03:00 +0200', message: 'yyy'}
      end

      before { build.update_attribute(:message, [message_in_db].to_json) }

       it 'appends message to build' do
         service.run

         res = JSON.parse(build.reload.message)
         res.second.symbolize_keys.should include(:position,:message,:timestamp)
       end
    end

    context 'when timestamp is nil' do
      let(:payload) { WORKER_PAYLOADS["build:test:#{event}"].merge('id' => build.id, 'timestamp' => nil ) }

      it 'does not append value' do
        service.run
        build.reload.message.should nil
      end
    end

    context 'when position is nil' do
      let(:payload) { WORKER_PAYLOADS["build:test:#{event}"].merge('id' => build.id, 'position' => nil ) }

      it 'does not append value' do
        service.run
        build.reload.message.should nil
      end
    end
  end
end
