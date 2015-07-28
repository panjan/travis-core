require 'spec_helper'

describe StashProvider do
  include Support::ActiveRecord

  let(:repo)    { Repository.new(owner_name: 'travis-ci', name: 'travis-ci') }
  let(:provider) { StashProvider.new(repo) }
  let(:content_params) { {project_key: 'travis-ci', repository_name: 'travis-ci', ref: '12345678', path: '.travis.yml'} }

  it 'uses configured protocol for private repository' do
    repo.private = true
    provider.source_url.should eq 'ssh://git@stash.yourcompany.com:22/travis-ci/travis-ci.git'
  end

  it 'uses http(s) protocol for public repository' do
    repo.private = false
    provider.source_url.should eq 'https://stash.yourcompany.com:443/scm/travis-ci/travis-ci.git'
  end
end
