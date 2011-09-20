class Slh::Cli::Initialize < Slh::Cli::CommandBase
  def default_options
   { :force_create => false,
     :template_dir => 'default_institution/default_templates'
   }
  end
  def option_parser
    return OptionParser.new do |opts|
      opts.on('-f','--force', "Destroy existing dir if exists") do
        @options[:force_create] = true
      end
      opts.on('-t','--template_dir=TEMPLATE_DIR', "Specify a config template dir for your institution") do |template_dir|
        @options[:template_dir] = template_dir
      end
    end
  end
  def perform_action
    if self.options[:force_create]
      if File.directory?(Slh.config_dir)
        FileUtils.rm_rf(Slh.config_dir)
        FileUtils.rm_rf(Slh::Models::CapistranoHelper.config_dir)
      end
    end
    begin
      FileUtils.mkdir(Slh.config_dir)
      Slh::Cli.instance.output "#{Slh.config_dir} and #{Slh.config_file} created."
    rescue Exception => e
      Slh::Cli.instance.output "Could not create directory, use --force option #{Slh.config_dir}", :exception => e
      exit
    end

    @template_dir = self.options[:template_dir] # targeted in config.rb.erb
    config_string = ERB.new(File.read(File.join(File.dirname(__FILE__),'..','templates',self.options[:template_dir],'config.rb.erb'))).result(binding)
    File.open(Slh.config_file,'w') {|f| f.write(config_string)}
    Slh::Models::CapistranoHelper.generate_deploy_dot_rb
    Slh::Cli.instance.output "Edit #{Slh.config_file} and run `slh generate`"
  end
end
