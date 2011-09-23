class Slh::Models::Version
  PREFIX = 'SLH_VERSION_'
  VERSION = "#{PREFIX}#{SecureRandom.hex(18)}"
end
