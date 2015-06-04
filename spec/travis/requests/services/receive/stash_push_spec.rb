require 'spec_helper'

describe Travis::Requests::Services::Receive::StashPush do

  let(:data)    { MultiJson.decode(STASH_PAYLOADS['gem-release']) }
  let(:payload) { Travis::Requests::Services::Receive.payload_for('push', data, 'stash') }

  describe 'repository' do
    it 'returns all attributes required for a Repository' do
      pending
      payload.repository.should == {
        :name => 'gem-release',
        :description => 'Release your gems with ease',
        :url => 'http://github.com/svenfuchs/gem-release',
        :owner_name => 'svenfuchs',
        :owner_email => 'me@svenfuchs.com',
        :owner_github_id => '2208',
        :owner_type => 'User',
        :private => false,
        :github_id => 100
      }
    end
  end

  describe 'commit' do
    it 'returns all attributes required for a Commit' do
      pending
      payload.commit.should == {
        :commit => '46ebe012ef3c0be5542a2e2faafd48047127e4be',
        :message => 'Bump to 0.0.15',
        :branch => 'master',
        :ref => 'refs/heads/master',
        :committed_at => '2010-10-27T04:32:37Z',
        :committer_name => 'Sven Fuchs',
        :committer_email => 'svenfuchs@artweb-design.de',
        :author_name => 'Christopher Floess',
        :author_email => 'chris@flooose.de',
        :compare_url => 'https://github.com/svenfuchs/gem-release/compare/af674bd...9854592'
      }
    end

    describe 'branch processing' do
      it 'returns head_commit if commits info is not present' do
        pending
        payload.event.data['head_commit'] = payload.event.data['commits'].first
        payload.event.data['commits'] = []
        payload.commit[:commit].should == '586374eac43853e5542a2e2faafd48047127e4be'
      end

      it 'returns master when ref is ref/heads/master' do
        pending
        payload.commit[:branch].should == 'master'
      end

      it 'returns travis when ref is ref/heads/travis' do
        pending
        payload.event.data['ref'] = "ref/heads/travis"
        payload.commit[:branch].should == 'travis'
      end

      it 'returns features/travis-ci when ref is ref/heads/features/travis-ci' do
        pending
        payload.event.data['ref'] = "ref/heads/features/travis-ci"
        payload.commit[:branch].should == 'features/travis-ci'
      end
    end

    it 'returns the last commit that isn\'t skipped' do
      pending
      payload = Travis::Requests::Services::Receive.payload_for('push', STASH_PAYLOADS['skip-last'])
      payload.commit[:commit].should == '586374eac43853e5542a2e2faafd48047127e4be'
    end

    it 'returns the last skipped commit if all commits are skipped' do
      pending
      payload = Travis::Requests::Services::Receive.payload_for('push', STASH_PAYLOADS['skip-last'])
      payload = Travis::Requests::Services::Receive.payload_for('push', STASH_PAYLOADS['skip-all'])
      payload.commit[:commit].should == '46ebe012ef3c0be5542a2e2faafd48047127e4be'
    end
  end
end
