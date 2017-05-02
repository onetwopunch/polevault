module Polevault
  DEFATULT_ROOT_TOKEN_PREFIX= 'token'
  DEFATULT_UNSEAL_PREFIX= 'unseal-key'

  module Helpers
    def camelcase(s)
      s.to_s.split('_').map(&:capitalize).join
    end

    def root_key_prefix
      fig.root_token_prefix || DEFATULT_ROOT_TOKEN_PREFIX
    end

    def unseal_key_prefix
      fig.unseal_key_prefix || DEFATULT_UNSEAL_PREFIX
    end

    def kv
      @kv ||= Kv.new(Figly::Settings.adapter)
    end

    def fig
      Figly::Settings
    end
  end
end
