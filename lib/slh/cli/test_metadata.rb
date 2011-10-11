# not used, not sure what exactly this would do.
# possibly deprecate?
class Slh::Cli::TestMetadata < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    Slh.strategies.each do |s|
    end
  end
end
