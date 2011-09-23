class Slh::Cli::CompareMetadata < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    # DEV_WISH_LIST: Clean up this mess... this stuff belongs somewhere else
    mismatch_found = false

    Slh.strategies.each do |strategy|
      strategy.hosts.each do |host|

        shib2_path = File.join(strategy.config_dir_for_host(host), 'shibboleth2.xml')
        raise "Can't find the generated shibboleth2.xml for #{host.name}" unless File.exists?(shib2_path)

        File.open(shib2_path, 'r') do |shib2|
          local = Nokogiri::XML(shib2)
          remote = Nokogiri::XML(host.sites.first.metadata)
          local.remove_namespaces!
          remote.remove_namespaces!
          local_version_node = local.at('ApplicationDefaults/CredentialResolver/Key/Name')
          remote_version_node = remote.at('KeyInfo/KeyName') # remote.at('md:KeyDescriptor/ds:Name')
          raise "No version nodes found in #{shib2.path}!" if local_version_node.blank?
          raise "No version nodes found in remote metadata for #{host.name}" if remote_version_node.blank?
          local_version = local_version_node.inner_text.sub(Slh::Models::Version::PREFIX, '')
          remote_version = remote_version_node.inner_text.sub(Slh::Models::Version::PREFIX, '')
          if local_version == remote_version
            Slh::Cli.instance.output "  OK        #{host.name}", {:highlight => :green}
          else
            Slh::Cli.instance.output "  MISMATCH  #{host.name}", {:highlight => :red}
            mismatch_found = true
          end
        end

      end
    end

    if mismatch_found
      Slh::Cli.instance.output "\nThe newest copy of shibboleth2.xml is not deployed to all of your hosts!"
    else
      Slh::Cli.instance.output "\nShibboleth2.xml is up-to-date on all of your hosts!"
    end
  end
end
