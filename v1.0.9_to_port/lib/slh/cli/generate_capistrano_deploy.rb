class Slh::Cli::GenerateCapistranoDeploy < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    Slh::Cli.instance.output "Generating a config/deploy.rb"
    self.generate_deploy_dot_rb
    Slh::Cli.instance.output "Will MUST change the TODO sections in this file and setup the symlinks correctly on your target servers for you to be able to do\ncap deploy HOST=somehost.com", :highlight => true
  end


  def config_dir
    'config'
  end

  def generate_deploy_dot_rb
    file_path = File.join(self.config_dir, 'deploy.rb')
    if File.exists?(file_path)
      Slh::Cli.instance.output "#{file_path} already exists, MISSION ABORT.", :exit => true
    end
    FileUtils.mkdir_p(self.config_dir)
    File.open(file_path, 'w') do |f|
      f.write(self.generate_config_file_content)
    end
  end

  def config_template_file_path
    File.join(File.dirname(__FILE__), '..', 'templates','deploy.rb.erb')
  end

  def generate_config_file_content
    ERB.new(File.read(self.config_template_file_path)).result(binding)
  end
end

