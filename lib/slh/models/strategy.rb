class Slh::Models::Strategy  < Slh::Models::Base
  class KeyOriginatorNotSpecified < Exception; end

  ##########################
  # CORE API METHODS BEGIN #
  ##########################
  def for_apache_host(host_name,&block)
    @hosts << Slh::Models::Host.new(host_name, self, &block)
  end

  def for_iis_host(host_name, &block)
    t=Slh::Models::Host.new(host_name, self, &block)
    t.host_type = :iis
    @hosts << t
  end
  ########################
  # CORE API METHODS END #
  ########################

  attr_reader :name, :hosts
  attr_accessor :sp_entity_id, :idp_metadata_url, :error_support_contact
  VALID_CONFIG_FILES = %w(shibboleth2.xml idp_metadata.xml assembled_sp_metadata.xml shib_apache.conf)
  def initialize(strategy_name, &block)
    @name = strategy_name
    @hosts = []
    if block_given?
      self.instance_eval(&block)
    end

    # The following are checks to ensure required "set" commands are done to set required values
    if self.sp_entity_id.nil?
      raise "All strategies must specify an entity ID"
    end
    if self.idp_metadata_url.nil?
      raise "All strategies must specify an IDP metadata URL"
    end
    if self.error_support_contact.nil?
      self.error_support_contact = "administrator"
    end
  end

  def idp_metadata
    if @idp_metadata.blank?
      url= URI.parse(self.idp_metadata_url)
      @http = Net::HTTP.new(url.host, url.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @http.open_timeout = 60
      @http.read_timeout = 60
      @idp_metadata_url_response = @http.get(url.path)
      case @idp_metadata_url_response
      when Net::HTTPSuccess
        @idp_metadata = @idp_metadata_url_response.body
      else
        raise "Got a non-200 http status code from #{self.idp_metadata_url}"
      end
    end
    @idp_metadata
  end

  # Parse it from the idp_metadata
  def idp_entity_id
    if @idp_entity_id.blank?
      doc=Nokogiri::XML(self.idp_metadata)
      doc.remove_namespaces!
      element=doc.at('//EntityDescriptor')
      attr = element.attribute_nodes.detect {|pp| pp.name == 'entityID'}
      if attr.blank?
        raise "hopefully not a bug in the XML parsing logic...Could not extract entityID from idp_metadata: #{self.idp_metadata}"
      end
      @idp_entity_id = attr.to_s 
    end
    @idp_entity_id
  end

  def config_dir
    File.join(Slh.config_dir,'generated',self.name.to_s)
  end


  def config_file_path(file_base_name,host,site=nil)
    if site.nil?
      File.join(host.config_dir,file_base_name)
    else
      File.join(site.config_dir,file_base_name)
    end
  end

  def generate_config_file_content(file_base_name,host,site=nil)
    # to be referenced in erb templates below
    @strategy = self
    @host = host
    @site = site
    case file_base_name
    when 'idp_metadata.xml'
      self.idp_metadata
    else
      ERB.new(self.config_template_content(file_base_name)).result(binding)
    end
  end

  def config_template_file_path(file_base_name)
    overridden = File.join(Slh.config_dir,'templates',"#{file_base_name}.erb")
    if File.exists?(overridden)
      template_file_path = overridden
    else
      template_file_path = File.join(File.dirname(__FILE__), '..', 'templates',"#{file_base_name}.erb")
    end

    if File.exists?(template_file_path)
      template_file_path 
    else
      raise "#{template_file_path} does not exist"
    end
  end

  def config_template_content(file_base_name)
    File.read(self.config_template_file_path(file_base_name))
  end

  def key_originator_site
    self.hosts.each do |host|
      host.sites.each do |site|
        if site.is_key_originator
          return site
        end
      end
    end
    raise KeyOriginatorNotSpecified.new("You must specify set :is_key_originator, true, on at least one site in a strategy")
  end
end
