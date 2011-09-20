class Slh::Models::CapistranoHelper
  def self.config_dir
    'config'
  end

  def self.generate_deploy_dot_rb
    FileUtils.mkdir_p(self.config_dir)
    File.open(File.join(self.config_dir, 'deploy.rb'), 'w') do |f|
      f.write(self.generate_config_file_content)
    end
  end

  def self.config_template_file_path
    File.join(File.dirname(__FILE__), '..', 'templates','deploy.rb.erb')
  end

  def self.generate_config_file_content
    ERB.new(File.read(self.config_template_file_path)).result(binding)
  end
end
