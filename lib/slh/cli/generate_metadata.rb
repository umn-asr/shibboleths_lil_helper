class Slh::Cli::GenerateMetadata < Slh::Cli::HostFilterableBase
  def perform_action
    Slh.strategies.each do |strategy|
      strategy.hosts.each do |host|
        next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
        host_dir = strategy.config_dir_for_host(host)
        file_path = 'sp_metadata_for_host_to_give_to_idp.xml'
        @strategy = strategy
        @host = host
        # Global config shared across vhosts like the X509Certificate
        # uses the first site arbirarily
        @first_site_for_host = @host.sites.first
        Slh::Cli.instance.output "Generating metadata for #{host.name}"
        File.open(File.join(host_dir, file_path),'w') do |f|
          f.write(ERB.new(strategy.config_template_content(file_path)).result(binding))
        end
      end
    end
  end
end
