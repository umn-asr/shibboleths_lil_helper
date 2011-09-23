class Slh::Models::Version
  PREFIX = 'SLH_VERSION_'
  VERSION = "#{PREFIX}#{UUIDTools::UUID.random_create.to_s}"
end
