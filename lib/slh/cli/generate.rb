class Slh::Cli::Generate < Slh::Cli::HostFilterableBase
  def perform_action
    Slh.strategies.each do |strategy|
      Slh::Cli.instance.output "Generating Native SP config files for strategy #{strategy.name.to_s}"
      FileUtils.rm_rf(strategy.config_dir)
      FileUtils.mkdir_p(strategy.config_dir)
      strategy.hosts.each do |host|
        next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
        Slh::Cli.instance.output "  Generating host config for #{host.name}"
        (Slh::Models::Strategy::VALID_CONFIG_FILES - ['assembled_sp_metadata.xml']).each do |cf|
          next if host.host_type == :iis && cf == 'shib_apache.conf' # not needed
          FileUtils.mkdir_p(strategy.config_dir_for_host(host))
          File.open(strategy.config_file_path(cf,host), 'w') {|f| f.write(strategy.generate_config_file_content(cf,host)) }
          Slh::Cli.instance.output "    Wrote #{strategy.config_file_path(cf,host)}"
        end
      end
    end
    Slh::Cli.instance.output "You MUST deploy these files your web servers and restart httpd and shibd for subsequent commands to work", :highlight => true
  end
end
