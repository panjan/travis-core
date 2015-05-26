module Travis
  module Stash
    module Services
      require 'travis/stash/services/fetch_config'
      class << self
        def register
          constants(false).each { |name| const_get(name) }
        end
      end
    end
  end
end
