class Slh::Models::Strategy
  attr_reader :name,:hosts,:sp_entity_id,:idp_metadata_url
  VALID_CONFIG_FILES = %w(shibboleth2.xml attribute-map.xml shib_apache22.conf idp_metadata.xml)
  def initialize(strategy_name,*args, &block)
    @name = strategy_name
    @hosts = []
    options = args.extract_options! 
    if options.has_key? :sp_entity_id
      @sp_entity_id = options[:sp_entity_id]
    else
      raise "All strategies must specify an entity ID"
    end

    if options.has_key? :idp_metadata_url
      @idp_metadata_url = options[:idp_metadata_url]
    else
      raise "All strategies must specify an IDP metadata URL"
    end

    if block_given?
      self.instance_eval(&block)
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
    VALID_CONFIG_FILES.each do |cf|
      File.open(self.config_file_path(cf), 'w') {|f| f.write(self.generate_config_file_content(cf)) }
    end
  end

  def config_dir
    File.join('shibboleths_lil_helper_generated_config',self.name.to_s)
  end

  # def now
  #   if @now.blank?
  #     @now = Time.now
  #   end
  #   @now
  # end
  def config_file_path(file_base_name)
    File.join(self.config_dir, self.config_file_name(file_base_name))
  end

  def config_file_name(file_base_name)
    validate_config_file_name(file_base_name)
    file_base_name
    # if file_base_name == 'idp_metadata.xml'
    #   file_base_name = (self.idp_metadata_url + self.now.to_s).gsub(/[^A-Za-z0-9:]/,'_') + '.xml'
    # end
    file_base_name
  end

  def generate_config_file_content(file_base_name)
    validate_config_file_name(file_base_name)
    case file_base_name
    when 'shibboleth2.xml'
      @strategy = self
      erb = ERB.new(self.config_template_content(file_base_name)).result(binding)
    when 'idp_metadata.xml'
      self.idp_metadata
    end
  end

  TODO_SP_VERSION_DIR = '2.4.2'
  TODO_SP_TYPE_DIR = 'apache'
  def config_template_file_path(file_base_name)
    validate_config_file_name(file_base_name)
    File.join(File.dirname(__FILE__), '..', 'templates',TODO_SP_TYPE_DIR,TODO_SP_VERSION_DIR,"#{file_base_name}.erb")
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
