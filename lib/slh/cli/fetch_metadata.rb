class Slh::Cli::FetchMetadata < Slh::Cli::HostFilterableBase
  def perform_action
    Slh.strategies.each do |strategy|
      strategy.hosts.each do |host|
        next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
        host.sites.each do |site|
          Slh::Cli.instance.output "Writing fetched metadata for #{site.name} to \n  #{site.fetched_metadata_path}"
          FileUtils.mkdir_p(site.config_dir)
          File.open(site.fetched_metadata_path,'w') do |f| 
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
