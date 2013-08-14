require "shibboleths_lil_helper/version"
require 'active_support/all'
require 'thor'
module ShibbolethsLilHelper
  extend ActiveSupport::Autoload
  autoload :Cli
end
Slh = ShibbolethsLilHelper
