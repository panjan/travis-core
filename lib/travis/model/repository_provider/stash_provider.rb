class StashProvider < RepositoryProvider

  attr_reader :repository

  def initiaize(repository)
    @repository = repository
  end

  def source_url
    "git@#{source_host}:#{stash_slug}.git"
  end

  def content_url(options)
    "https://#{source_host}/#{stash_slug}/browse/#{options[:path]}?at=#{options[:ref]}".to_s
  end

  def fetch_content(file_url)
  end

  def source_host
    (Travis.config.stash and Travis.config.stash.source_host) || raise('Travis.config.stash.source_host not provided')
  end

  private

    def stash_slug
      #TODO: stash has projects and users
      @stash_slug ||= ['projects', repository.owner_name, 'repos', repository.name].join('/')
    end

end
