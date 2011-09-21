class Slh::Cli::AssembleMetadata < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    Slh.strategies.each do |s|
      s.assemble_sp_metadata
      Slh::Cli.instance.output <<-EOS
Generated assembled metadta for strategy \"#{s.name.to_s}\" in #{s.config_dir}

You MUST send these metadata files to your IdP (identity provider)

EOS
    end
  end
end
