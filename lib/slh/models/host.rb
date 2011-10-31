# This model represents the actual hostname/machine the shib SP instance lives on
class Slh::Models::Host < Slh::Models::Base
  ##########################
  # CORE API METHODS BEGIN #
  ##########################
  def for_site(site_name, &block)
    @sites << Slh::Models::Site.new(site_name,&block)
  end
  ########################
  # CORE API METHODS END #
  ########################

  attr_reader :name, :sites
  attr_accessor :host_type, :shib_prefix
  def initialize(host_name,&block)
    @name = host_name
    @host_type = :apache
    @sites = []
    if block_given?
      self.instance_eval(&block)
    end

    if self.sites.length == 0
      raise "Misconfiguration on host=#{self.name}: You must define at least one site for a host even if it's the same name as the host"
    end
    if self.host_type == :iis
      if self.sites.detect {|x| x.site_id.nil?}
        raise "If your :host_type is iis, you must specify :site_id for all of your sites"
      end
    end
  end


  # File.join('', 'asdf.txt') returns '/asdf.txt'. We need a way to accomodate
  # shib_prefix when needed, but avoiding values like '/shibboleth2.xml' when
  # a prefix isn't set.
  #
  def prefixed_filepath_for(filename)
    filepath = filename
    unless @shib_prefix.nil?
      filepath = File.join(@shib_prefix, filename)
    end
    filepath
  end
end
