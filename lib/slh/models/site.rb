class Slh::Models::Site
  attr_reader :name, :paths
  def initialize(site_name,*args,&block)
    @name = site_name 
    @paths = []
    if block_given?
      self.instance_eval(&block)
    end
  end

  # DSL method that encapsulates Apache directives like the following
  #
  # <Location /secure>
  #   AuthType shibboleth
  #   ShibRequestSetting requireSession 1
  #   ShibUseEnvironment On
  #   require valid-user
  # </Location>
  #
  def protect(site_path, *args, &block)
    @paths << Slh::Models::SitePath.new(site_path, *args, &block)
  end
end
