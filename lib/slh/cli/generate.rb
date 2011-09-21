class Slh::Cli::Generate < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    Slh.strategies.each do |s|
      s.generate_config
      Slh::Cli.instance.output <<-EOS
Generated config for strategy \"#{s.name.to_s}\" in #{s.config_dir}

You MUST deploy these genereated files to your web server before running `slh metadata`

EOS
    end
  end
end
