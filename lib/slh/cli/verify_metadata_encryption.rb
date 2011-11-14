class Slh::Cli::VerifyMetadataEncryption < Slh::Cli::HostFilterableBase
  def perform_action
    Slh.strategies.each do |strategy|
      broken = false
      Slh::Cli.instance.output "Iterating hosts for strategy #{strategy.name}"
      key_originator_site = strategy.key_originator_site
      strategy.hosts.each do |host|
        next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
        Slh::Cli.instance.output "Iterating sites for host #{host.name}"
        host.sites.each do |site|
          begin 
            if key_originator_site.x509_certificate_string == site.x509_certificate_string
              Slh::Cli.instance.output "  X509Certificate matches for #{site.name} ", :highlight => :green
            else
              Slh::Cli.instance.output "  Mismatching X509Certificate for #{site.name}, WILL NOT WORK", :highlight => :red
              broken = true
            end
          rescue Slh::Models::Site::CouldNotGetMetadata => e
            Slh::Cli.instance.output "  Could not get metadata from #{site.name}, Slh::Models::Site::CouldNotGetMetadata exception thrown, message=#{e.message}, this site will not work", :highlight => :red
            broken = true
          end
        end
      end
      if broken
        Slh::Cli.instance.output "To fix issues highlighted above need to copy the sp-key.pem and sp-cert.pem files from host #{key_originator_site.parent_host.name} to the hosts associated with each of the sites listed above", :highlight => true
      end
    end
  end
end

