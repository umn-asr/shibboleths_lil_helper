class Slh::Cli::FetchMetadata < Slh::Cli::HostFilterableBase
  def perform_action
    Slh.strategies.each do |strategy|
      strategy.hosts.each do |host|
        next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
        host.sites.each do |site|
          site_dir = File.join(strategy.config_dir_for_host(host),site.name.to_s)
          file_path = 'fetched_metadata.xml'
          Slh::Cli.instance.output "Fetching metadata for #{site.name}"
          FileUtils.mkdir_p(site_dir)
          File.open(File.join(site_dir,file_path),'w') do |f| 
            begin
              f.write(site.metadata)
            rescue Slh::Models::Site::CouldNotGetMetadata => e
              Slh::Cli.instance.output "NOT FOUND metadata not found at #{site.metadata_url}", :highlight => :red
              Slh::Cli.instance.output "  Error message: #{e.message}"
              next # skip this site
            rescue Timeout::Error => e
              Slh::Cli.instance.output "  TIMEOUT at #{site.metadata_url}", :highlight => :red
              Slh::Cli.instance.output "    Remote metadata not available at #{site.metadata_url}, exception message: #{e.message}"
              next # skip this site
            end
          end
        end
      end
    end
  end
end
