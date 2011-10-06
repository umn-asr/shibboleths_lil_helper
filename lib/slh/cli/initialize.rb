class Slh::Cli::Initialize < Slh::Cli::CommandBase
  def default_options
   { :force_create => false }
  end
  def option_parser
    return OptionParser.new do |opts|
      opts.on('-f','--force', "Destroy existing dir if exists") do
        @options[:force_create] = true
      end
    end
  end
  def perform_action
    Slh::Cli.instance.output "Generating shibboleths_lil_helper/config.rb as a starting point"
    if self.options[:force_create]
      if File.directory?(Slh.config_dir)
        FileUtils.rm_rf(Slh.config_dir)
        FileUtils.rm_rf(Slh::Models::CapistranoHelper.config_dir)
      end
    end
    begin
      FileUtils.mkdir(Slh.config_dir)
    rescue Exception => e
      Slh::Cli.instance.output "Could not create directory, use --force option #{Slh.config_dir}", :exception => e
      exit
    end

    config_string = ERB.new(File.read(File.join(File.dirname(__FILE__),'..','templates','config.rb.erb'))).result(binding)
    File.open(Slh.config_file,'w') {|f| f.write(config_string)}
    Slh::Models::CapistranoHelper.generate_deploy_dot_rb
    Slh::Cli.instance.output "You should go edit #{Slh.config_file} to reflect your organizations Shib setup", :highlight => :red
  end
end
