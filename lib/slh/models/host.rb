# This model represents the actual hostname/machine the shib SP instance lives on
class Slh::Models::Host < Slh::Models::Base
  attr_reader :name, :sites, :server_type
  def initialize(host_name,*args,&block)
    @name = host_name
    @server_type = :apache
    @sites = []
    if block_given?
      self.instance_eval(&block)
    end

    if self.server_type == :iis
      if self.sites.detect {|x| x.site_id.nil?}
        raise "If your :server_type is iis, you must specify :site_id for all of your sites"
      end
    end
  end

  def for_site(site_name,*args,&block)
    @sites << Slh::Models::Site.new(site_name,*args, &block)
  end
end
