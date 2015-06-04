class StashProvider < RepositoryProvider

  attr_reader :repository

  def initiaize(repository)
    @repository = repository
  end

  def source_url
    "#{git_source_protocol}://git@#{source_host}:#{git_source_port}/" +
      "#{repository.owner_name}/#{repository.name}.git"
  end

  def source_host
    config.source_host || raise('Travis.config.stash.source_host not provided')
  end

  def source_port
    config.source_port || 443
  end

  def source_protocol
    config.source_protocol || 'https'
  end

  def git_source_port
    config.git_source_port || 22
  end

  def git_source_protocol
    config.git_source_protocol || 'ssh'
  end

  private

    def config
      Travis.config.stash || {}
    end

    def stash_slug
      #TODO: stash has projects and users
    end

end
