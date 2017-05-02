module Polevault
  class Migration
    attr_reader :vault, :config, :kv
    def initialize(vault, config, kv)
      @vault = vault
      @config = config
      @kv = kv
    end

    def migrate
      raise NotImplemented
    end
  end
end
