class Slh::Cli::FetchMetadata < Slh::Cli::CommandBase
  def default_options
   { }
  end
  def perform_action
    Slh.strategies.each do |strategy|
      strategy.hosts.each do |host|
        host.sites.each do |site|
          puts "Fetching metadata for #{site.name}"
        end
      end
    end
  end
end
