class Slh::Cli::Generate < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    Slh.strategies.each do |s|
      Slh::Cli.instance.output "Generating Native SP config files for #{s.name.to_s} strategy"
      s.generate_config
    end
    Slh::Cli.instance.output "You MUST deploy these files your web servers for subsequent commands to work", :highlight => true
  end
end
