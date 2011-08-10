module Slh
  extend ActiveSupport::Autoload
  autoload :ClassMethods
  extend Slh::ClassMethods

  module Models
    extend ActiveSupport::Autoload
    autoload :Host
    autoload :App
    autoload :Strategy
  end
end
