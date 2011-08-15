class Slh::Models::Strategy  < Slh::Models::Base
  attr_reader :name,:hosts,:sp_entity_id,:idp_metadata_url, :error_support_contact
  VALID_CONFIG_FILES = %w(shibboleth2.xml attribute-map.xml idp_metadata.xml shib_for_vhost.conf)
  def initialize(strategy_name,*args, &block)
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
      raise "All strategies must specify an error support contact for when Shibboleth breaks/fails/etc."
    end
  end

  def idp_metadata
    if @idp_metadata.blank?
      url= URI.parse(self.idp_metadata_url)
      @http = Net::HTTP.new(url.host, url.port)
      @http.use_ssl = true
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

  # DSL method
  def for_host(host_name,*args,&block)
    @hosts << Slh::Models::Host.new(host_name,*args, &block)
  end

  def generate_config
    FileUtils.mkdir_p(self.config_dir)
    self.hosts.each do |h|
      %w(shibboleth2.xml attribute-map.xml idp_metadata.xml).each do |cf|
        FileUtils.mkdir_p(File.join(self.config_dir,h.name.to_s))
        File.open(self.config_file_path(cf,h), 'w') {|f| f.write(self.generate_config_file_content(cf,h)) }
      end
    end
    self.hosts.each do |h|
      h.sites.each do |s|
        FileUtils.mkdir_p(File.join(self.config_dir,h.name.to_s,s.name.to_s))
        File.open(self.config_file_path('shib_for_vhost.conf',h,s), 'w') {|f| f.write(self.generate_config_file_content('shib_for_vhost.conf',h,s)) }
      end
    end
    # VALID_CONFIG_FILES.each do |cf|
    #   File.open(self.config_file_path(cf), 'w') {|f| f.write(self.generate_config_file_content(cf)) }
    # end
  end

  def config_dir
    File.join(Slh.config_dir,'generated',self.name.to_s)
  end

  def config_file_path(file_base_name,host,site=nil)
    File.join(self.config_dir, self.config_file_name(file_base_name,host,site))
  end

  def config_file_name(file_base_name,host,site=nil)
    validate_config_file_name(file_base_name)
    if site.nil?
      File.join(host.name, file_base_name)
    else
      File.join(host.name, site.name, file_base_name)
    end
  end

  def generate_config_file_content(file_base_name,host,site=nil)
    validate_config_file_name(file_base_name)
    # to be referenced in erb templates below
    @strategy = self
    @host = host
    @site = site
    case file_base_name
    when 'shibboleth2.xml','attribute-map.xml','shib_for_vhost.conf'
      ERB.new(self.config_template_content(file_base_name)).result(binding)
    when 'idp_metadata.xml'
      self.idp_metadata
    else
      raise "dont know how to generate config for #{file_base_name}"
    end
  end

  def config_template_file_path(file_base_name)
    validate_config_file_name(file_base_name)
    File.join(File.dirname(__FILE__), '..', 'templates',"#{file_base_name}.erb")
  end

  def config_template_content(file_base_name)
    File.read(self.config_template_file_path(file_base_name))
  end

  protected
    def validate_config_file_name(file_base_name)
      unless VALID_CONFIG_FILES.include?(file_base_name)
        raise "#{file_base_name} is not a valid shib SP config file name, must be one of the following #{VALID_CONFIG_FILES.join(',')}"
      end
    end
  # def config_file_dir
  #   if @config_file_dir.blank?
  #     @config_file_dir = Time.now.to_s.gsub(/[^A-Za-z0-9:-]/,'_') # Wed_Aug_10_15:54:06_-0500_2011
  #   end
  #   @config_file_dir
  # end
end
