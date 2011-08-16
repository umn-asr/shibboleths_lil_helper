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
  def to_iis_directive(*args)
    options = args.extract_options!
    @strategy = options[:strategy]
    @host = options[:host]
    @site = options[:site]
    "TODO, do magic w #{@strategy} #{@host} #{@site}"
    # ERB.new(self.iis_directive_template_file_content).result(binding)
  end

end
