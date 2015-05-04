
class RepositoryProvider #< Travis::Model
  require 'travis/model/repository_provider/github_provider'
  require 'travis/model/repository_provider/stash_provider'

  # FIXME: belongs_to :repository
  attr_reader :repository

  def initialize(repository)
    @repository = repository
  end

  def source_host
    raise 'needs to be implemented in subclass'
  end
end


