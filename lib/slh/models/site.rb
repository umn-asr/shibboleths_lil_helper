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
    unless site_path.match(/^\//)
      raise "protect statements must begin with a slash, aka /"
    end
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
    "https://#{self.name}/Shibboleth.sso/Metadata"
  end

  def self.metadata_site_specific_xpaths
    ['//md:ArtifactResolutionService', '//md:SingleLogoutService','//md:AssertionConsumerService']
  end
  def metadata_site_specific_xml
    if @metadata_site_specific_xml.blank?
      @metadata_site_specific_xml = ''
      self.class.metadata_site_specific_xpaths.each do |xpath|
        @metadata_site_specific_xml << self.metadata_nokogiri.xpath(xpath).to_a.join("\n")
        @metadata_site_specific_xml << "\n"
      end
    end
    @metadata_site_specific_xml
  end

  def metadata_non_site_specific_xml
    if @metadata_non_site_specific_xml.blank?
      cloned_metadata_nokogiri = self.metadata_nokogiri.clone
      self.class.metadata_site_specific_xpaths.each do |xpath|
        cloned_metadata_nokogiri.xpath(xpath).remove
      end
      @metadata_non_site_specific_xml = cloned_metadata_nokogiri.to_s
    end
    @metadata_non_site_specific_xml
  end

  # def iis_directive_template_file_content
  #   f_name = File.join(File.dirname(__FILE__), '..', 'templates','iis_directives',"#{self.flavor.to_s}.xml.erb")
  #   unless File.exists?(f_name)
  #     raise "No iis directive at #{f_name}, perhaps the flavor youve specified is illegit #{self.flavor} (too illegit to quit -- M.C. Hammer)"
  #   end
  #   File.read(f_name)
  # end

  # This is a little different than the to_apache_directive on SitePath
  # because the particular bit of XML includes 2 layers...it's not just
  # a function of the SitePath...
  #
  # See https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapHowTo
  # for details on this logic
  #
  def iis_xml_payload_for_flavor(flavor)
    if flavor == :authentication_optional
      'authType="shibboleth" requireSession="false"'
    elsif [:authentication_required,:authentication_required_for_specific_users].include?(flavor)
      'authType="shibboleth" requireSession="true"'
    else 
      raise "No iis_xml_payload_for_flavor flavor=#{flavor}"
    end
  end
  def to_iis_directive(*args)
    host_begin = ''
    host_end = '</Host>'
    path_strings = []
    if self.paths.first.name == '/'
      host_begin = <<-EOS
<!-- Shibboleths Lil Helper flavor=#{self.paths.first.flavor} protection for entire site -->
<Host name="#{self.name}" #{self.iis_xml_payload_for_flavor(self.paths.first.flavor)} redirectToSSL="443" >"
EOS
    else
      host_begin = "<Host name=\"#{self.name}\" redirectToSSL=\"443\" >"
    end
    self.paths.each do |p|
      next if p.name == '/' # Already dealt with/baked into the <Host> Xml
      if p.flavor == :authentication_required_for_specific_users
        path_strings << <<-EOS
          <!-- Shibboleths Lil Helper flavor=#{p.flavor} -->
          <Path name="#{p.name}" #{self.iis_xml_payload_for_flavor(p.flavor)}>
            <AccessControl>
              <AND>
                <Rule require="user">#{p.specific_users.join(' ')}</Rule>
              </AND>
            </AccessControl>
          </Path>
        EOS
      else
        path_strings << "<Path name=\"#{p.name}\" #{self.iis_xml_payload_for_flavor(p.flavor)} />"
      end
    end
    return "#{host_begin}\n#{path_strings.join("\n")}\n#{host_end}"
  end

end
