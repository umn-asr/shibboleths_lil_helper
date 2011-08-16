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
    # EXAMPLE1
    # for_site 'asr-web-dev2.oit.umn.edu' do
    #   set :site_id, "1351780944"
    #   protect '/'
    # EXAMPLE2
    # for_site 'asr-web-dev2.oit.umn.edu' do
    #   set :site_id, "1351780944"
    #   protect '/' do
    #     set :flavor :authentication_optional
   # INTERPRETATION
    #   Single auth rule for entire site, no <Path> nodes needed
    # if self.paths.length == 1 && self.paths.first.name == '/'
    #   host_attrs = flavors[self.paths.first.flavor]
    #   raise "No iis config info for #{self.paths.first.flavor}" if host_attrs.blank?
    #   return <<-EOS
    #     <Host name="#{self.name}" #{host_attrs} redirectToSSL="443" />
    #   EOS
    # else
    #   # setup the opening host tag
    #   s = <<-EOS
    #     <Host name="#{self.name}" redirectToSSL="443">
    #   EOS
    #   self.paths.each do |p|
    #     if p.name == '/'

    #     end
    #   end
    # end
    "TODO, do magic w #{@strategy} #{@host} #{@site}"
    # ERB.new(self.iis_directive_template_file_content).result(binding)
  end

end
