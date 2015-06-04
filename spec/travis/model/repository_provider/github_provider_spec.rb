require 'spec_helper'

describe GithubProvider do
  include Support::ActiveRecord

  let(:repo)    { Repository.new(owner_name: 'travis-ci', name: 'travis-ci') }
  let(:provider) { GithubProvider.new(repo) }
  let(:content_params) { {project_key: 'travis-ci', repository_name: 'travis-ci', ref: '12345678', path: '.travis.yml'} }

  describe 'config_url' do
    it 'returns the api url to the .travis.yml file on github' do
      provider.content_url(content_params).should == 'https://api.github.com/repos/travis-ci/travis-ci/contents/.travis.yml?ref=12345678'
    end

    it 'returns the api url to the .travis.yml file on github with a gh endpoint given' do
      GH.set api_url: 'http://localhost/api/v3'
      provider.content_url(content_params).should == 'http://localhost/api/v3/repos/travis-ci/travis-ci/contents/.travis.yml?ref=12345678'
    end
  end

end
