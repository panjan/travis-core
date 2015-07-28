class StashProvider < RepositoryProvider

  attr_reader :repository

  def initiaize(repository)
    @repository = repository
  end

  def name
    'stash'
  end

  def source_url
    if repository.private?
      "#{git_source_protocol}://git@#{source_host}:#{git_source_port}/" +
        "#{repository.owner_name}/#{repository.name}.git"
    else
      "#{source_protocol}://#{source_host}:#{source_port}/scm/" +
        "#{repository.owner_name}/#{repository.name}.git"
    end
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

  def api_url
    "#{Travis.config.stash.api_url}/projects/#{repository.owner_name}/repos/#{repository.name}"
  end

  private

    def config
      Travis.config.stash || {}
    end

    def stash_slug
      #TODO: stash has projects and users
    end

end
