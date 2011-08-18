# Children should define .default_options and option_parser
class Slh::Cli::CommandBase
  attr_reader :args,:option_parser,:options
  def default_options
   { }  # CHILD SHOULD DEFINE
  end
  def option_parser
    OptionParser.new # CHILD SHOULD DEFINE
  end

  def initialize(args)
    @options = self.default_options
    if args.nil?
      @args = [] 
    else
      @args = args.dup
    end
  end
  def load_config
    require Slh.config_file
    if Slh.strategies.empty?
      Slh::Cli.instance.output "NO strategies found in #{Slh.config_file}, make sure to edit this before running the generate command", :error => true
    end
  end
  def execute
    self.option_parser.parse!(self.args)
    self.load_config unless self.class == Slh::Cli::Initialize
    self.perform_action
  end
end
