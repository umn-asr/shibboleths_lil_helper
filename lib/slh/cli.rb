module Slh
  class Cli # Command Line Interface
    extend ActiveSupport::Autoload
    autoload :CommandBase  # abstract class
    autoload :HostFilterableBase # abstract class
    autoload :Initialize
    autoload :Generate
    autoload :FetchMetadata
    autoload :CompareMetadata
    autoload :GenerateMetadata
    autoload :GenerateCapistranoDeploy
    autoload :CopyTemplatesToOverride
    autoload :TestMetadata
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

               ___,@
               /  <
          ,_  /    \  _,                    He'll help you create consistent
      ?    \`/______\`/                     config XML for your Shibboleth-Native 
   ,_(_).  |; (e  e) ;|                     Service-Provider servers (Apache or IIS)
    \___ \ \/\   7  /\/    _\8/_            without pulling your hair out in frustration.
        \/\   \'=='/      | /| /|
         \ \___)--(_______|//|//|
          \___  ()  _____/|/_|/_|
             /  ()  \    `----'             He knows several commands listed below
            /   ()   \                      invoked like: "slh initialize".
           '-.______.-'
   jgs   _    |_||_|    _                   Append "--help" like "slh initialize --help"
        (@____) || (____@)                  to learn about the options each command can
         \______||______/                   take.
MAIN COMMANDS (in usage order)
  initialize
    Creates a shibboleths_lil_helper/config.rb file that is the place where
    you specify all authentication settings for all hosts, sites, and paths
    in your organization

  generate
    Generates a bunch of Native shibboleth configuration files and puts them in
    a directory structure under "shibboleths_lil_helper/generated" that mirrors
    your config.rb file.  These files can then be copied to your target hosts.

  metadata
    Assembles your Service Provider metadata for each host
    and creates a sp_metadata_for_host_to_give_to_idp.xml to give your Identity Provider.
    It goes out and hits urls like https://somehost.com/Shibboleth.sso/Metadata to see if you
    have already deployed generated content out in the wild (which your idp will require to make stuff work)

OPTIONAL COMMANDS
  generate_capistrano
    Creates a config/deploy.rb for you as a starting point to use with Capistrano.
    To install and prep for use with capistrano
      Install:    gem install capistrano
      Capify dir: capify .
      Edit config/deploy.rb
      cap deploy HOST=somehost.com

  copy_templates_to_override
    This copies all of the Native Shib config templates into your local directory where your can
    customize them to your heart's content.  Meant to also be used with the set_custom :var, "somevalue" to
    put special stuff in your shibboleth configuration files not covered by the defaults of the tool.
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
    Outputs info from shibboleths_lil_helper/config.rb
        EOS
        exit
      when 'initialize'
        klass = Slh::Cli::Initialize
      when 'generate'
        klass = Slh::Cli::Generate
      when 'metadata'
        klass = [Slh::Cli::CompareMetadata,Slh::Cli::FetchMetadata,Slh::Cli::GenerateMetadata] # possible deprecate Slh::Cli::TestMetadata?
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
