module Slh
  class Cli # Command Line Interface
    extend ActiveSupport::Autoload
    autoload :CommandBase
    autoload :Initialize
    autoload :Generate
    autoload :AssembleMetadata

    attr_reader :args,:action
    def output(msg,*args)
      options = args.extract_options!
      s=msg
      unless options[:exception].blank?
        s << "Exception = #{options[:exception].class.to_s}, message=#{options[:exception].message}"
      end
      puts s
      if options[:error]
        puts "Exiting..."
        exit
      end
    end
    def parse_options_and_delegate(args)
      if args.nil?
        @args = [] 
      else  
        @args = args.dup
      end
      $stdout.sync = true # no output buffering
      case @args.first
      when 'initialize',nil   # DEFAULT IF NONE-SPECIFIED
        klass = Slh::Cli::Initialize
      when 'generate'
        klass = Slh::Cli::Generate
      when 'metadata'
        klass = Slh::Cli::AssembleMetadata
      else 
        raise "Invalid slh action"
      end
      @action = klass.new(@args[1..-1])
      @action.execute
    end
    def self.execute
      @@instance = self.new
      @@instance.parse_options_and_delegate(ARGV)
    end
    def self.instance
      raise "must hit execute to get this piece rolling" if @@instance.nil?
      @@instance
    end
  end
end
