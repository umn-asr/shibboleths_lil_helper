module Slh
  extend ActiveSupport::Autoload
  autoload :ClassMethods
  extend Slh::ClassMethods

  autoload :Cli
  module Models
    extend ActiveSupport::Autoload
    autoload :Base
    autoload :Strategy
    autoload :Host
    autoload :Site
    autoload :SitePath
  end
end
