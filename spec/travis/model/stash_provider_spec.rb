require 'spec_helper'

describe StashProvider do
  include Support::ActiveRecord

  let(:repo) { Repository.new(owner_name: 'travis-ci', name: 'travis-ci', provider: 'stash') }
  let(:stash_provider) { described_class.new(repo) }

  before :each do
    Travis.config.stash = { source_host: 'stash.example.com' }
  end

  it '#source_url' do
    stash_provider.source_url.should == 'ssh://git@stash.example.com:22/travis-ci/travis-ci.git'
  end

  it '#source_host' do
    stash_provider.source_host.should == 'stash.example.com'
  end
end


