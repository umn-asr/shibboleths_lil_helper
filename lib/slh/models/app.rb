class Slh::Models::App
  attr_reader :url,:auth_rules
  def initialize(base_url,*args,&block)
    @url = base_url
    @auth_rules = []
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
  def protect_location(url_path, *args, &block)
    @auth_rules << Slh::Models::AppAuthRule.new(url_path,:location, *args, &block)
  end
end
