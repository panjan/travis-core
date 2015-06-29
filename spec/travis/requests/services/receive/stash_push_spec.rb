require 'spec_helper'

class FakeStashClient
  def initialize(data, commit_data = STASH_COMMITS_PAYLOAD)
    @data = data
    @commit_data = commit_data
  end

  def repository(project, repo)
    @data['repository']
  end

  def  commits_for(*a)
    @commit_data
  end
end

describe Travis::Requests::Services::Receive::StashPush do

  let(:data)    { MultiJson.decode(STASH_PAYLOADS['gem-release']) }
  let(:payload) { Travis::Requests::Services::Receive.payload_for('push', data, 'stash') }

  describe 'repository' do
    it 'returns all attributes required for a Repository' do
      Travis::Stash.stubs(:client).returns(FakeStashClient.new(data))
      payload.repository.should == {
        :name => 'test-repo',
        :owner_name => 'FIN',
        :owner_stash_id => nil,
        :owner_type => 'Organization',
        :private => false,
        :stash_id => 789,
      }
    end
  end

  describe 'commit' do
    it 'returns all attributes required for a Commit' do
      Travis::Stash.stubs(:client).returns(FakeStashClient.new(data))
      payload.commit.should == {
        :commit => 'a6656906d4bd0ed38e8dd142f690e74509c63961',
        :message => 'br8',
        :branch => 'master',
        :ref => 'refs/heads/master',
        :committed_at => '2015-05-28T09:19:09Z',
        :author_name => 'Lukas Svoboda'
        #:compare_url => 'https://github.com/svenfuchs/gem-release/compare/af674bd...9854592'
      }
    end

    describe 'branch processing' do
      it 'returns master when ref is ref/heads/master' do
        Travis::Stash.stubs(:client).returns(FakeStashClient.new(data))
        payload.commit[:branch].should == 'master'
      end

      it 'returns travis when ref is ref/heads/travis' do
        Travis::Stash.stubs(:client).returns(FakeStashClient.new(data))
        payload.data['refChange']['refId'] = "ref/heads/travis"
        payload.commit[:branch].should == 'travis'
      end

      it 'returns features/travis-ci when ref is ref/heads/features/travis-ci' do
        Travis::Stash.stubs(:client).returns(FakeStashClient.new(data))
        payload.data['refChange']['refId'] = "ref/heads/features/travis-ci"
        payload.commit[:branch].should == 'features/travis-ci'
      end
    end

    it 'returns the last commit that isn\'t skipped' do
      Travis::Stash.stubs(:client).returns(FakeStashClient.new(data, STASH_COMMITS_PAYLOAD_SKIP_LAST))
      payload.commit[:commit].should == '3d201c35ce972ae069fe21781fca729aa459d89f'
    end

    it 'returns the last skipped commit if all commits are skipped' do
      Travis::Stash.stubs(:client).returns(FakeStashClient.new(data, STASH_COMMITS_PAYLOAD_SKIP_ALL))
      payload.commit[:commit].should == 'a6656906d4bd0ed38e8dd142f690e74509c63961'
    end
  end
end
