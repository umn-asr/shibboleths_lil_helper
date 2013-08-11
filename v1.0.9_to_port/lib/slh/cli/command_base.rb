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
  def output_header
    Slh::Cli.instance.output "\n<<<< BEGIN #{self.class.to_s} >>>>\n"
  end
  def output_footer
    Slh::Cli.instance.output "\n<<<< END #{self.class.to_s} >>>>\n"
  end
  def execute
    Slh.load_config unless self.class == Slh::Cli::Initialize
    self.option_parser.parse!(self.args)
    self.output_header
    self.perform_action
    self.output_footer
  end
end
