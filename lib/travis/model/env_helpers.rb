module Travis::Model::EnvHelpers
  CONFIG_ENV_PATTERN = /(SECURE )?([\w]+)=(("|')(.*?)(\3)|\$\(.*?\)|[^"' ]+)/

  def obfuscate_env(vars)
    vars = [vars] unless vars.is_a?(Array)
    vars.compact.map do |var|
      repository.key.secure.decrypt(var) do |decrypted|
        Travis::Helpers.obfuscate_env_vars(decrypted)
      end
    end
  end

  def vars2hash(vars)
    vars.scan(CONFIG_ENV_PATTERN).map do |var|
      #do not return SECURE (var[0]) variables
      var[0] ? nil : var[1, 2]
    end.compact.to_h
  end
  private :vars2hash

  def config_env_hash
    @config_env_hash ||= vars2hash(config[:env].to_s)
  end

  def config_global_env_hash
    @config_global_env_hash ||= vars2hash(config[:global_env].to_s)
  end

  def env_hash
    @env_hash ||= config_global_env_hash.dup.update(config_env_hash)
  end
end
