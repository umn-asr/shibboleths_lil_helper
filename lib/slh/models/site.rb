class Slh::Models::Site < Slh::Models::Base
  attr_reader :name, :paths
  def initialize(site_name,*args,&block)
    @name = site_name 
    @paths = []
    if block_given?
      self.instance_eval(&block)
    end
  end

  def protect(site_path, *args, &block)
    @paths << Slh::Models::SitePath.new(site_path, *args, &block)
  end
end
