class Slh::Cli::Generate < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    require Slh.config_file
    if Slh.strategies.empty?
      Slh::Cli.instance.output "NO strategies found in #{Slh.config_file}, make sure to edit this before running the generate command", :error => true
    else
      Slh.strategies.each do |s|
        s.generate_config
        Slh::Cli.instance.output "Generated config for strategy \"#{s.name.to_s}\" in #{s.config_dir}"
      end
    end
  end
end
