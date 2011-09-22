# This model represents the actual hostname/machine the shib SP instance lives on
class Slh::Models::Host < Slh::Models::Base
  attr_reader :name, :sites
  attr_accessor :host_type, :shib_prefix
  def initialize(host_name,*args,&block)
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

  def for_site(site_name,*args,&block)
    @sites << Slh::Models::Site.new(site_name,*args, &block)
  end

  # Builds the single metadata file for all sites contained within it
  # to share with the IDP for each host
  def assembled_sp_metadata
    non_site_specific_nokogiri = self.sites.first.metadata_non_site_specific_nokogiri.clone
    a_request_initiator = non_site_specific_nokogiri.xpath('//md:Extensions').children.detect {|x| x.name == "RequestInitiator"}
    if a_request_initiator.nil?
      raise "Could not find a RequestInitiator xml node (as a child of md:Extensions)"
    end
    self.sites.reverse.each do |site|
      non_site_specific_nokogiri.xpath('//md:KeyDescriptor').after(
<<-EOS


<!-- #{site.name} -->
#{site.metadata_site_specific_xml}
EOS
)
      # TODO: THIS IS BUGGY/BRITTLE/TRASH should find a better way to
# inject the RequestInitiator node in there... 
      if "https://#{site.name}/Shibboleth.sso/Login" == a_request_initiator.attributes["Location"].value
        # no nothing, this is already in the XML
      else
        a_cloned_request_initiator = a_request_initiator.clone
        a_cloned_request_initiator.attributes["Location"].value = "https://#{site.name}/Shibboleth.sso/Login"
        non_site_specific_nokogiri.xpath('//md:Extensions').children.after(a_cloned_request_initiator)
      end
    end
    non_site_specific_nokogiri.to_s
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
