module Slh
  class Cli # Command Line Interface
    extend ActiveSupport::Autoload
    autoload :CommandBase
    autoload :Initialize
    autoload :Generate
    autoload :AssembleMetadata # TODO: Deprecate
    autoload :FetchMetadata
    autoload :CompareMetadata
    autoload :GenerateMetadata
    autoload :TestMetadata

    attr_reader :args,:action

    def output(msg,*args)
      Slh.command_line_output(msg,*args)
    end

    def parse_options_and_delegate(args)
      if args.nil?
        @args = [] 
      else  
        @args = args.dup
      end
      $stdout.sync = true # no output buffering
      case @args.first
      when nil
        puts <<-'EOS'
  This is Shibboleth's Lil Helper.
               ___,@
               /  <
          ,_  /    \  _,                    He's kinda dumb, but is helpful by
      ?    \`/______\`/                     making config XML that you can use
   ,_(_).  |; (e  e) ;|                     in your Apache or IIS Shibboleth
    \___ \ \/\   7  /\/    _\8/_            Native Service Provider implementations.
        \/\   \'=='/      | /| /|
         \ \___)--(_______|//|//|
          \___  ()  _____/|/_|/_|
             /  ()  \    `----'             He knows several commands listed below
            /   ()   \                      invoked like: "slh initialize".
           '-.______.-'
   jgs   _    |_||_|    _                   Append "--help" like "slh initialize --help"
        (@____) || (____@)                  to learn about the options each command can
         \______||______/                   take.
COMMANDS (in usage order)
  initialize
    Creates a shibboleths_lil_helper/config.rb file that is the place where
    you specify all authentication settings for all hosts, sites, and paths
    in your organization

  generate
    Generates a bunch of Native shibboleth configuration files and puts them in
    a directory structure under "shibboleths_lil_helper/generated" that mirrors
    your config.rb file.  These files can then be copied to your target hosts.
    Also generates a Capistrano "config/deploy.rb"

  <DEPLOY> (could be cap deploy TODO:JOE REVISIT THIS ONCE STABLE)
    There is no command for this, you need to place your config out on the target hosts
    in the right place and restart shibd and httpd.  The metadata command will only work if this
    has been done.

  metadata
    Assembles your Service Provider metadata for each host by hitting URLs like
      https://some.site.in.your.config.rb/Shibboleth.sso/Metadata
    and creating your assembed_sp_metadata.xml file in the "generated" folder.
    Before shibboleth will work, you'll need to provide this to your Identity Provider.
        EOS
        exit
      when 'initialize'
        klass = Slh::Cli::Initialize
      when 'generate'
        klass = Slh::Cli::Generate
      when 'metadata'
        # klass = Slh::Cli::AssembleMetadata
        klass = [Slh::Cli::CompareMetadata,Slh::Cli::FetchMetadata,Slh::Cli::GenerateMetadata, Slh::Cli::TestMetadata]
      else 
        raise "Invalid slh action"
      end
      if klass.kind_of? Array
        klass.each do |k|
          @action = k.new(@args[1..-1])   # everything except "slh" aka "initialize -f"
          @action.execute
        end
      else
        @action = klass.new(@args[1..-1]) # everything except "slh" aka "initialize -f"
        @action.execute
      end
    end
    def self.execute
      @@instance = self.new
      @@instance.parse_options_and_delegate(ARGV)
    end
    @@instance = nil
    def self.instance
      raise "must hit execute to get this piece rolling" if @@instance.nil?
      @@instance
    end
  end
end
