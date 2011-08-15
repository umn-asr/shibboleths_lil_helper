# This model represents the actual hostname/machine the shib SP instance lives on
class Slh::Models::Host
  attr_reader :name, :sites
  def initialize(host_name,*args,&block)
    @name = host_name
    @sites = []
    if block_given?
      self.instance_eval(&block)
    end
  end

  def for_site(site_name,*args,&block)
    @sites << Slh::Models::Site.new(site_name,*args, &block)
  end
end
