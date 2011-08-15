class Slh::Cli::Initialize
  attr_reader :args,:option_parser,:options
  def initialize(args)
    if args.nil?
      @args = [] 
    else
      @args = args.dup
    end
    @options = {
      :force_create => false
    }
    @option_parser = OptionParser.new do |opts|
      opts.on('-f','--force', "Destroy existing dir if exists") do |value|
        @options[:force_create] = true
      end
    end
    @option_parser.parse!(args)
    perform_action 
  end
  def perform_action
    if self.options[:force_create]
      if File.directory?(Slh.config_dir)
        FileUtils.rm_rf(Slh.config_dir)
      end
    end
    begin
      FileUtils.mkdir(Slh.config_dir)
      Slh::Cli.instance.output "#{Slh.config_dir} and #{Slh.config_file} created."
    rescue Exception => e
      Slh::Cli.instance.output "Could not create directory, use --force option #{Slh.config_dir}", :exception => e
      exit
    end
    config_string = ERB.new(File.read(File.join(File.dirname(__FILE__),'..','templates','config.rb.erb'))).result(binding)
    File.open(Slh.config_file,'w') {|f| f.write(config_string)}
    Slh::Cli.instance.output "Edit #{Slh.config_file} and run `slh generate`"
  end
end
