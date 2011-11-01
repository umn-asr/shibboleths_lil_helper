module Slh
  class Cli # Command Line Interface
    extend ActiveSupport::Autoload
    autoload :CommandBase  # abstract class
    autoload :HostFilterableBase # abstract class
    autoload :Initialize
    autoload :Generate
    autoload :FetchMetadata
    autoload :CompareMetadata
    autoload :VerifyMetadataEncryption
    autoload :GenerateMetadata
    autoload :GenerateCapistranoDeploy
    autoload :CopyTemplatesToOverride
    autoload :DescribeConfig

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
                                            He'll help you create consistent
               ___,@                        config XML for your Shibboleth-Native 
               /  <                         Service-Provider servers (Apache or IIS)
          ,_  /    \  _,                    without pulling your hair out in frustration.
      ?    \`/______\`/
   ,_(_).  |; (e  e) ;|                     He knows several commands listed below
    \___ \ \/\   7  /\/    _\8/_            invoked like: "slh initialize".
        \/\   \'=='/      | /| /|
         \ \___)--(_______|//|//|           Append "--help" like "slh initialize --help"
          \___  ()  _____/|/_|/_|           to learn about the options each command can
             /  ()  \    `----'             take
            /   ()   \
           '-.______.-'                     It is STRONLY RECOMMENDED to keep generated files
         _    |_||_|    _                   produced by this tool under source control--this sneaky
        (@____) || (____@)                  little elf does not prompt before overwriting files.
         \______||______/
MAIN COMMANDS (in usage order)
  initialize
    Creates a shibboleths_lil_helper/config.rb.
    This is where you put ALL OF YOUR shibboleth SP config info for your organization.
    Shibboleth's Lil Helper operates on this structure to provide all of the funcionality below.

  generate
    Generates shibboleth2.xml (and others) for deployment to each of your target hosts.
    Don't forget to restart shibd and httpd on each host after you've updated these files.

  verify_metadata
    Makes sure all sites expose a URL like site.com/Shibboleth.sso/Metadata.
    Detects differences in locally generated config with deployed config.
    Detects encryption key inconsistency issues.

  generate_metadata
    Assembles your SP metadata for each strategy to give to your IDP

OPTIONAL COMMANDS
  generate_capistrano
    Creates a Capistrano config/deploy.rb for automating deployment.  (see Capistrano website)
    To install and prep for use with capistrano
      Install:    gem install capistrano
      Capify dir: capify .
      Edit config/deploy.rb
      cap deploy HOST=somehost.com

  copy_templates_to_override
    Copies config templates into your local directory should you need to customize things beyond what the tool
    provides.
    This feature is designed to be used with the 'set_custom :var, "somevalue"' syntax in the config.rb
    After running this command, you could add the following to one of the shibboleths_lil_helper/templates files:
      <% if @strategy.respond_to? :dogz %>
        <%= @strategy.dogz %>
      <% end %>
    then in the shibboleths_lil_helper/config.rb
      set_custom :dogz, "YEA DOGZ"
    it would result in "YEA DOGZ" appearing in rendered template

    This feature is like a gun in church: You probably don't need it, but if you do, its good to have.
    (read: don't use this unless you really need it.)

  describe
    Summarizes the configuration described in shibboleths_lil_helper/config.rb

OTHER DOCUMENTATION SOURCES (not just this tool)
  https://wiki.shibboleth.net/
    The official Shibboleth Wiki
  (within this project--the doc folder)
    There are lots of short little developer oriented tips we used while creating this tool.

        EOS
        exit
      when 'initialize'
        klass = Slh::Cli::Initialize
      when 'generate'
        klass = Slh::Cli::Generate
      when 'verify_metadata'
        klass = [Slh::Cli::FetchMetadata, Slh::Cli::CompareMetadata, Slh::Cli::VerifyMetadataEncryption]
      when 'generate_metadata'
        klass = [Slh::Cli::FetchMetadata, Slh::Cli::CompareMetadata,Slh::Cli::VerifyMetadataEncryption, Slh::Cli::GenerateMetadata]
      when "generate_capistrano"
        klass = Slh::Cli::GenerateCapistranoDeploy
      when "copy_templates_to_override"
        klass = Slh::Cli::CopyTemplatesToOverride
      when "describe"
        klass = Slh::Cli::DescribeConfig
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
