require 'spec_helper'

describe GithubProvider do
  include Support::ActiveRecord

  let(:repo)    { Repository.new(owner_name: 'travis-ci', name: 'travis-ci') }
  let(:provider) { GithubProvider.new(repo) }
  let(:content_params) { {project_key: 'travis-ci', repository_name: 'travis-ci', ref: '12345678', path: '.travis.yml'} }

    it 'uses configured protocol for private repository' do
      repo.private = true
      provider.source_url.should eq 'git@github.com:travis-ci/travis-ci.git'
    end

    it 'uses git protocol for public repository' do
      repo.private = false
      provider.source_url.should eq 'git://github.com/travis-ci/travis-ci.git'
    end
end
