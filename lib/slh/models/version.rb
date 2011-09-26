class Slh::Models::Version
  PREFIX = 'SLH_VERSION_'
  VERSION = "#{PREFIX}#{ActiveSupport::SecureRandom.hex(18)}"
end
