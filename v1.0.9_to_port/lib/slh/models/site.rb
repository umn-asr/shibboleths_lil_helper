class Slh::Models::Site < Slh::Models::Base
  ##########################
  # CORE API METHODS BEGIN #
  ##########################
  def protect(site_path, &block)
    if site_path == '/' && !@paths.empty?
      raise "If you want to protect the entire site, you must specify \"protect '/'\" before all other site path rules"
    end
    @paths << Slh::Models::SitePath.new(site_path, self, &block)
  end
  ##########################
  # CORE API METHODS END   #
  ##########################
  class CouldNotGetMetadata < Exception; end
  attr_reader :name, :paths, :parent_host

  # This indicates the site is where all other sites get their encryption keys from
  # and where the metadata X509Certificate comes from
  attr_accessor :is_key_originator

  # site_id is for hosts who's host_type == :iis
  attr_accessor :site_id 
  def initialize(site_name,parent_host,&block)
    @parent_host = parent_host
    @name = site_name
    @paths = []
    self.is_key_originator = false
    if block_given?
      self.instance_eval(&block)
    end
    if self.paths.empty?
      raise "No protect statements for site #{site_name}, you must protect at least 1 path for every site.  Adding a \"protect\" statement should make this error go away"
    end
  end

  def metadata
    if @metadata.blank?
      url = URI.parse(self.metadata_url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.open_timeout = 5
      http.read_timeout = 5
      begin
        the_metadata_for_site = http.get(url.path)
      rescue
        raise CouldNotGetMetadata.new("Could not https GET #{self.metadata_url}, have you deployed your generated shib config files to this machine and restarted shibd?")
      end
      case the_metadata_for_site
      when Net::HTTPSuccess
        @metadata = the_metadata_for_site.body
      else
        raise CouldNotGetMetadata.new("Got a non-200 http status code (actual=#{the_metadata_for_site.code}) from #{self.metadata_url}")
      end
    end
    @metadata
  end

  def metadata_nokogiri
    if @metadata_nokogiri.blank?
      @metadata_nokogiri = Nokogiri::XML(self.metadata)
    end
    @metadata_nokogiri
  end

  def metadata_url
    "#{self.to_https_prefixed_name}/Shibboleth.sso/Metadata"
  end

  # Gets interpolated into the
  #   sp_metadata_for_entity_id_to_give_to_idp.xml.erb # file
  #
  def x509_certificate_string
    t=self.metadata_nokogiri.clone
    t.remove_namespaces!
    the_xpath = "//KeyDescriptor/KeyInfo/X509Data/X509Certificate"
    node = t.xpath(the_xpath)
    if node.blank?
      raise "Could not extract X509Certificate from #{site.name}"
    else
      node.inner_text
    end
  end


  
  # See these for specs
  # https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapHowTo
  # https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapPath
  # https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapPathRegex
  def to_auth_request_map_directive
    common_host_begin = "<Host name=\"#{self.name}\" redirectToSSL=\"443\" applicationId=\"#{self.name}\" "
    host_end = '</Host>'
    path_strings = []
    if self.paths.first.name == '/'
      host_begin = common_host_begin + " #{self.auth_request_map_xml_payload_for_flavor(self.paths.first.flavor)}>"
    else
      host_begin =  common_host_begin + ">" # just close the tag, we all good
    end
    self.paths.each do |p|
      next if p.name == '/' # Already dealt with/baked into the <Host> Xml
      if p.flavor == :authentication_required_for_specific_users
        path_strings << <<-EOS
          <!-- Shibboleths Lil Helper flavor=#{p.flavor} -->
          <Path name="#{p.name}" #{self.auth_request_map_xml_payload_for_flavor(p.flavor)}>
            <AccessControl>
              <Rule require="user">#{p.specific_users.join(' ')}</Rule>
            </AccessControl>
          </Path>
        EOS
      else
        path_strings << "<Path name=\"#{p.name}\" #{self.auth_request_map_xml_payload_for_flavor(p.flavor)} />"
      end
    end
    return "#{host_begin}\n#{path_strings.join("\n")}\n#{host_end}"
  end

  def to_https_prefixed_name
    "https://#{self.name}"
  end

  def config_dir
    File.join(self.parent_host.config_dir,self.name.to_s)
  end

  def fetched_metadata_path
    File.join(self.config_dir,'fetched_metadata.xml')
  end

  protected
    # Internal helper, used in <RequestMapper> 
    # returned strings are interpoleted into <Host> or <Path>
    #
    def auth_request_map_xml_payload_for_flavor(flavor)
      if flavor == :authentication_optional
        'authType="shibboleth" requireSession="false"'
      elsif [:authentication_required,:authentication_required_for_specific_users].include?(flavor)
        'authType="shibboleth" requireSession="true"'
      else 
        raise "No auth_request_map_xml_payload_for_flavor flavor=#{flavor}"
      end
    end
end
