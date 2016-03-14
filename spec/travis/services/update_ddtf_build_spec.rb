require 'spec_helper'

describe Travis::Services::UpdateDdtfBuild do
  include Support::ActiveRecord

  let(:service) { described_class.new(event: event, data: payload) }
  let(:payload) { WORKER_PAYLOADS["build:test:#{event}"].merge('id' => build.id) }
  let(:build)   { Factory(:build, state: :created, started_at: nil, finished_at: nil) }

  before :each do
    build.matrix.delete_all
  end

  describe '#cancel_build_in_worker' do
    let(:event) { :start }

    it 'sends cancel event to the worker' do
      publisher = mock('publisher')
      service.stubs(:publisher).returns(publisher)
      publisher.expects(:publish).with({ stopped_by: nil }.to_json)

      service.cancel_build_in_worker
    end
  end

  describe 'event: receive' do
    let(:event) { :receive }

    context 'when build is canceled' do
      before { build.update_attribute(:state, :canceled) }

      it 'does not update state' do
        service.expects(:cancel_build_in_worker)

        service.run
        build.reload.state.should == 'canceled'
      end
    end

    it 'sets the build state to received' do
      service.run
      build.reload.state.should == 'received'
    end

    it 'sets the build received_at' do
      service.run
      build.reload.received_at.to_s.should == '2011-01-01 00:02:00 UTC'
    end
  end

  describe 'event: start' do
    let(:event) { :start }

    context 'when build is canceled' do
      before { build.update_attribute(:state, :canceled) }

      it 'does not update state' do
        service.expects(:cancel_build_in_worker)

        service.run
        build.reload.state.should == 'canceled'
      end
    end

    it 'sets the build state to started' do
      service.run
      build.reload.state.should == 'started'
    end

    it 'sets the build started_at' do
      service.run
      build.reload.started_at.to_s.should == '2011-01-01 00:02:00 UTC'
    end

    it 'sets the repository last_build_state to started' do
      service.run
      build.reload.repository.last_build_state.should == 'started'
    end

    it 'sets the repository last_build_started_at' do
      service.run
      build.reload.repository.last_build_started_at.to_s.should == '2011-01-01 00:02:00 UTC'
    end
  end

  describe 'event: error' do
    let(:event) { :error }

    before :each do
      build.repository.update_attributes(last_build_state: :started)
    end

    context 'when build is canceled' do
      before { build.update_attribute(:state, :canceled) }

      it 'does not update state' do
        service.expects(:cancel_build_in_worker)

        service.run
        build.reload.state.should == 'canceled'
      end
    end

    it 'sets the build state to errored' do
      service.run
      build.reload.state.should == 'errored'
    end

    it 'sets the build finished_at' do
      service.run
      build.reload.finished_at.to_s.should == '2011-01-01 00:03:00 UTC'
    end

    it 'sets the repository last_build_state to errored' do
      service.run
      build.reload.repository.last_build_state.should == 'errored'
    end

    it 'sets the repository last_build_finished_at' do
      service.run
      build.reload.repository.last_build_finished_at.to_s.should == '2011-01-01 00:03:00 UTC'
    end
  end

  describe 'event: reset' do
    let(:event) { :reset }

    before :each do
      build.repository.update_attributes(last_build_state: :passed)
    end

    it 'sets the build state to created' do
      service.run
      build.reload.state.should == 'created'
    end

    it 'resets the build started_at' do
      service.run
      build.reload.started_at.should be_nil
    end

    it 'resets the repository last_build_state to started' do
      service.run
      build.reload.repository.last_build_state.should == 'created'
    end

    it 'resets the repository last_build_started_at' do
      service.run
      build.reload.repository.last_build_started_at.should be_nil
    end
  end
end
