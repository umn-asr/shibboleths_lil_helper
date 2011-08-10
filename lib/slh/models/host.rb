# This model represents the actual hostname/machine the shib SP instance lives on
class Slh::Models::Host
  attr_reader :name, :apps
  def initialize(host_name,*args,&block)
    @name = host_name
    @apps = []
    if block_given?
      self.instance_eval(&block)
    end
  end

  def for_app(app_name,*args,&block)
    @apps << Slh::Models::App.new(app_name,*args, &block)
  end
end
