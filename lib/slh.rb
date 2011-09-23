module Slh
#  PROJECT_URL = 'https://github.com/joegoggins/shibboleths_lil_helper'
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
    autoload :CapistranoHelper
    autoload :Version
  end
end
