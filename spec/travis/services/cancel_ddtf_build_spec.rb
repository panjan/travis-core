require 'spec_helper'

describe Travis::Services::CancelDdtfBuild do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository) }
  let(:build)   { Factory(:build, repository: repo) }
  let(:params)  { { id: build.id, source: 'tests' } }
  let(:user)    { Factory(:user) }
  let(:service) { described_class.new(user, params) }

  describe 'run' do
    context 'when matrix with cancelable jobs' do
      let!(:passed_job) { Factory(:test, repository: repo, state: :passed) }
      let!(:job)    { Factory(:test, repository: repo, state: :created) }

      before do
        build.matrix.destroy_all
        build.matrix << passed_job
        build.matrix << job
      end

      it 'should cancel the build if it\'s cancelable with empty job matrix' do
        publisher = mock('publisher')
        service.stubs(:publisher).returns(publisher)
        publisher.expects(:publish).with(stopped_by: user.login)

        expect {
          service.run
        }.to change { build.reload.state }

        build.state.should == 'canceled'
      end
    end

    context 'when job matrix is empty' do
      before do
        build.matrix.destroy_all
      end

      it 'should cancel the build if it\'s cancelable' do
        service.stubs(:can_cancel?).returns(true)

        publisher = mock('publisher')
        service.stubs(:publisher).returns(publisher)
        publisher.expects(:publish).with(stopped_by: user.login)

        expect {
          service.run
        }.to change { build.reload.state }

        build.state.should == 'canceled'
      end
    end

    it 'should not cancel the job if it\'s not cancelable' do
      build.stubs(:cancelable?).returns(false)

      expect {
        service.run
      }.to_not change { build.reload.state }
    end

  end
end
