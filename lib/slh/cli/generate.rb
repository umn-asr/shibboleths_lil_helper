class Slh::Cli::Generate < Slh::Cli::HostFilterableBase
  def perform_action
    Slh.strategies.each do |strategy|
      Slh::Cli.instance.output "Generating Native SP config files for strategy #{strategy.name.to_s}"
      FileUtils.rm_rf(strategy.config_dir)
      FileUtils.mkdir_p(strategy.config_dir)
      strategy.hosts.each do |host|
        next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
        Slh::Cli.instance.output "  Generating host config for #{host.name}"
        Slh::Models::Strategy::VALID_CONFIG_FILES.each do |cf|
          next if host.host_type == :iis && cf == 'shib_apache.conf' # not needed
          FileUtils.mkdir_p(host.config_dir)
          File.open(strategy.config_file_path(cf,host), 'w') {|f| f.write(strategy.generate_config_file_content(cf,host)) }
          Slh::Cli.instance.output "    Wrote #{strategy.config_file_path(cf,host)}"
          if cf == 'shib_apache.conf'
            Slh::Cli.instance.output "      copy this into /etc/httpd/conf.d or somewhere apache can read it are target host", :highlight => :green
          else
            if host.shib_prefix.nil?
              Slh::Cli.instance.output "      copy this into /etc/shibboleth for this host on target host", :highlight => :green
            else
              Slh::Cli.instance.output "      copy this into #{host.prefixed_filepath_for(cf)} on target host", :highlight => :green
            end
          end
        end
      end

      originator_host = strategy.key_originator_site.parent_host
      Slh::Cli.instance.output "\ncopy sp-key.pem sp-cert.pem from host #{originator_host.name} to ALL target hosts.", :highlight => :green
      Slh::Cli.instance.output "  This makes the X509Certificate stuff in all metadata for all sites associated with an entity_id match"
    end

    Slh::Cli.instance.output "You MUST deploy these files your web servers and restart httpd and shibd for subsequent commands to work", :highlight => true
  end
end
