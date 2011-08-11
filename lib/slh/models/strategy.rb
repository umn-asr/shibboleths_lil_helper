class Slh::Models::Strategy
  attr_reader :name,:hosts
  VALID_CONFIG_FILES = %w(shibboleth2.xml attribute-map.xml shib_apache22.conf)
  def initialize(strategy_name,*args, &block)
    @name = strategy_name
    @hosts = []
    if block_given?
      self.instance_eval(&block)
    end
  end

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

  def config_file_path(file_base_name)
    validate_config_file_name(file_base_name)
    File.join(self.config_dir, file_base_name)
  end

  def generate_config_file_content(file_base_name)
    validate_config_file_name(file_base_name)
    case file_base_name
    when 'shibboleth2.xml'
      "THIS IS SOME XML"
    end
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
