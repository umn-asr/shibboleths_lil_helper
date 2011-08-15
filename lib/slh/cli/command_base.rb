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
  def execute
    self.option_parser.parse!(self.args)
    self.perform_action
  end
end
