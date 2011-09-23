class Slh::Cli::FetchMetadata < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    Slh.strategies.each do |strategy|
      strategy.hosts.each do |host|
        host.sites.each do |site|
          site_dir = File.join(strategy.config_dir_for_host(host),site.name.to_s)
          file_path = 'fetched_metadata.xml'
          Slh::Cli.instance.output "Fetching metadata for #{site.name}"
          FileUtils.mkdir_p(site_dir)
          File.open(File.join(site_dir,file_path),'w') {|f| f.write(site.metadata) }
        end
      end
    end
  end
end
