require 'spec_helper'

describe Travis::Services::UpdateDdtfBuildMessage do
  include Support::ActiveRecord

  let(:service) { described_class.new(event: event, data: payload) }
  let(:payload) { WORKER_PAYLOADS["build:test:#{event}"].merge('id' => build.id) }
  let(:build)   { Factory(:build, state: :created, started_at: nil, finished_at: nil ) }

  before :each do
    build.matrix.delete_all
  end

  describe 'event: message', focused: true do
    let(:event) { :message }

    it 'appends message to build' do
      service.run
      build.reload.execution_logs.should_not be_nil
    end

    it 'appends whole message to build' do
      service.run

      messages = build.reload.execution_logs
      message = messages.first

      message.position.should eq payload['position'].to_i
      message.timestamp.should eq DateTime.parse(payload['timestamp'])
      message.message.should eq payload['message']
    end

    context 'whem some message is present' do
      let(:execution_log) do
        ExecutionLog.new(position: 0, timestamp: '2011-01-01 00:03:00', message: 'yyy')
      end

      before { build.update_attribute(:execution_logs, [execution_log]) }

      it 'appends message to build' do
        service.run
        build.reload.execution_logs.should have(2).items
      end
    end

    context 'when timestamp is nil' do
      let(:payload) { WORKER_PAYLOADS["build:test:#{event}"].merge('id' => build.id, 'timestamp' => nil ) }

      it 'does not append value' do
        service.run
        build.reload.execution_logs.should be_empty
      end
    end

    context 'when position is nil' do
      let(:payload) { WORKER_PAYLOADS["build:test:#{event}"].merge('id' => build.id, 'position' => nil ) }

      it 'does not append value' do
        service.run
        build.reload.execution_logs.should be_empty
      end
    end
  end
end
