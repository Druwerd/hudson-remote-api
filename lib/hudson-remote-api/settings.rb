module Hudson
  class Settings

    Configuration = Struct.new(:host, :user, :password, :version, :crumb, :proxy_host, :proxy_port)
    attr_accessor :configuration

    DEFAULTS = {
      :host => 'http://localhost:8080', 
      :user => nil, 
      :password => nil, 
      :version => nil, 
      :crumb => true,
      :proxy_host => nil,
      :proxy_port => nil
    }

    def initialize(settings_hash={})
      settings_hash = DEFAULTS.merge(settings_hash)
      self.configuration = Configuration.new

      self.configuration.host       = settings_hash[:host]
      self.configuration.user       = settings_hash[:user]
      self.configuration.password   = settings_hash[:password]
      self.configuration.version    = settings_hash[:version]
      self.configuration.crumb      = settings_hash[:crumb]
      self.configuration.proxy_host = settings_hash[:proxy_host]
      self.configuration.proxy_port = settings_hash[:proxy_port]
    end

  end
end