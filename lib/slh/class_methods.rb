module Slh::ClassMethods
  @@strategies = []
  def strategies; @@strategies; end
  def for_strategy(strategy_sym, *args, &block)
    @@strategies << Slh::Models::Strategy.new(strategy_sym, *args, &block)
  end

  def with(strategy_sym)
    t = @@strategies.detect {|x| x.name == strategy_sym}
    raise "Unknown strategy #{t}" if t.blank?
    t
  end

  def config_dir
    'shibboleths_lil_helper'
  end
  def config_file
    File.join self.config_dir,'config.rb'
  end

  VALID_CONFIG_FILES = %w(config.rb shibboleth2.xml attribute-map.xml idp_metadata.xml shib_for_vhost.conf)
  def generate_config_file_content(file_base_name)
    validate_config_file_name(file_base_name)
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
    File.join(File.dirname(__FILE__), '..', 'templates',TODO_SP_VERSION_DIR,"#{file_base_name}.erb")
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

end
