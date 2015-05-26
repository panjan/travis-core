class GithubProvider < RepositoryProvider
    attr_reader :repository

  def initiaize(repository)
    @repository = repository
  end

  def name
    'github'
  end

  def source_url
    (repository.private? || private_mode?) ? "git@#{source_host}:#{repository.slug}.git": "git://#{source_host}/#{repository.slug}.git"
  end

  def source_host
    Travis.config.github.source_host || 'github.com'
  end

  def api_url
    "#{Travis.config.github.api_url}/repos/#{repository.slug}"
  end

  private

  def private_mode?
    source_host != 'github.com'
  end
end


