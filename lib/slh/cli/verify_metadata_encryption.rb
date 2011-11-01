class Slh::Cli::VerifyMetadataEncryption < Slh::Cli::HostFilterableBase
  def perform_action
    Slh.strategies.each do |strategy|
      strategy.hosts.each do |host|
        next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
        host.sites.each do |site|

        end
      end
    end
        
    # Note: This depends on FetchMetadata happening first
    Slh::Cli.instance.output "yo yo yo"
  end
end

