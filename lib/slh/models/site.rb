class Slh::Models::Site < Slh::Models::Base
  attr_reader :name, :paths
  attr_accessor :site_id # site_id is for hosts who's host_type == :iis
  def initialize(site_name,*args,&block)
    @name = site_name 
    @paths = []
    if block_given?
      self.instance_eval(&block)
    end
  end

  def protect(site_path, *args, &block)
    if site_path == '/' && !@paths.empty?
      raise "If you want to protect the entire site, you must specify \"protect '/'\" before all other site path rules"
    end
    @paths << Slh::Models::SitePath.new(site_path, *args, &block)
  end

  def metadata
    if @metadata.blank?
      url = URI.parse(self.metadata_url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.open_timeout = 60
      http.read_timeout = 60
      begin
        the_metadata_for_site = http.get(url.path)
      rescue
        raise "Could not https GET #{self.metadata_url}, have you deployed your generated shib config files to this machine and restarted shibd?"
      end
      case the_metadata_for_site
      when Net::HTTPSuccess
        @metadata = the_metadata_for_site.body
      else
        raise "Got a non-200 http status code from #{self.metadata_url}"
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

  # Gets interpolated into the sp_metadata_for_host_to_give_to_idp.xml
  # file
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

  def auth_request_map_xml_payload_for_flavor(flavor)
    if flavor == :authentication_optional
      'authType="shibboleth" requireSession="false"'
    elsif [:authentication_required,:authentication_required_for_specific_users].include?(flavor)
      'authType="shibboleth" requireSession="true"'
    else 
      raise "No auth_request_map_xml_payload_for_flavor flavor=#{flavor}"
    end
  end

  def to_auth_request_map_directive(*args)
    host_begin = ''
    host_end = '</Host>'
    path_strings = []
    if self.paths.first.name == '/'
      host_begin = <<-EOS
<!-- Shibboleths Lil Helper flavor=#{self.paths.first.flavor} protection for entire site -->
<Host name="#{self.name}" #{self.auth_request_map_xml_payload_for_flavor(self.paths.first.flavor)} redirectToSSL="443" >
EOS
    else
      host_begin = "<Host name=\"#{self.name}\" redirectToSSL=\"443\" applicationId=\"#{self.name}\" >"
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
end
