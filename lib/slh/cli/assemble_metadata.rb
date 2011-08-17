class Slh::Cli::AssembleMetadata < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    Slh.strategies.each do |s|
      s.assemble_sp_metadata
    end
  end
end
