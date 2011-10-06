class Slh::Cli::CopyTemplatesToOverride < Slh::Cli::CommandBase
  def default_options
   { }
  end

  def perform_action
    Slh::Cli.instance.output "Copying all of the erb templates from Shibboleth's Lil Helper to your local directory"
    FileUtils.cp_r(File.join(File.dirname(__FILE__), '..', 'templates'),Slh.config_dir)
    Slh::Cli.instance.output "These templates will be used instead of the defaults in the Shibboleth's Lil Helper Rubygem"
  end
end

