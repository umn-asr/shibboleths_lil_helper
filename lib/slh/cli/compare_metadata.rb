class Slh::Cli::CompareMetadata < Slh::Cli::HostFilterableBase
  def perform_action
    # DEV_WISH_LIST: Clean up this mess... this stuff belongs somewhere else
    mismatch_found = false

    Slh.strategies.each do |strategy|
      strategy.hosts.each do |host|
        next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])

        raise "Can't find the generated shibboleth2.xml for #{host.name}" unless File.exists?(host.shibboleth2_path)

        local = Nokogiri::XML(File.read(host.shibboleth2_path)) #Nokogiri::XML(shib2)
        remote_first_site = host.sites.first

        begin
          remote = Nokogiri::XML(remote_first_site.metadata)
        rescue Slh::Models::Site::CouldNotGetMetadata => e
          Slh::Cli.instance.output "  NOT FOUND  #{host.name}", :highlight => :red
          Slh::Cli.instance.output "    Remote metadata not available at #{remote_first_site.metadata_url}, exception message: #{e.message}"
          mismatch_found = true
          next # skip this host
        rescue Timeout::Error => e
          Slh::Cli.instance.output "  TIMEOUT #{host.name}", :highlight => :red
          Slh::Cli.instance.output "    Remote metadata not available at #{remote_first_site.metadata_url}, exception message: #{e.message}"
          mismatch_found = true
          next # skip this host
        end
        local.remove_namespaces!
        remote.remove_namespaces!
        local_version_node = local.at('ApplicationDefaults/CredentialResolver/Key/Name')
        remote_version_node = remote.at('KeyInfo/KeyName') # remote.at('md:KeyDescriptor/ds:Name')
        raise "No version nodes found in #{shib2.path}!" if local_version_node.blank?
        raise "No version nodes found in remote metadata for #{host.name}" if remote_version_node.blank?
        local_version = local_version_node.inner_text.sub(Slh::Models::Version::PREFIX, '')
        remote_version = remote_version_node.inner_text.sub(Slh::Models::Version::PREFIX, '')
        if local_version == remote_version
          Slh::Cli.instance.output "  OK        #{host.name}", :highlight => :green
        else
          Slh::Cli.instance.output "  MISMATCH  #{host.name}", :highlight => :red
          Slh::Cli.instance.output "    From metadata gathered at #{remote_first_site.metadata_url}"
          mismatch_found = true
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
