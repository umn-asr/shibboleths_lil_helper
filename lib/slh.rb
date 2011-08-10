module Slh
  extend ActiveSupport::Autoload
  autoload :ClassMethods
  extend Slh::ClassMethods

  module Models
    extend ActiveSupport::Autoload
    autoload :Strategy
    autoload :Host
    autoload :App
    autoload :AppAuthRule
  end
end
