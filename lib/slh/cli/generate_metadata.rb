class Slh::Cli::GenerateMetadata < Slh::Cli::HostFilterableBase
  def perform_action
    template_rel_file_path ='sp_metadata_for_entity_id_to_give_to_idp.xml'
    Slh.strategies.each do |strategy|
      Slh::Cli.instance.output "Generating #{template_rel_file_path} for strategy #{strategy.name}, sp_entity_id=#{strategy.sp_entity_id}"
      if @options[:filter].kind_of?(String)
        matching_hosts = strategy.hosts.select {|h| h.name.match(@options[:filter])}
        if matching_hosts.empty?
          Slh::Cli.instance.output "No hosts matched in this strategy for filter #{@options[:filter]}, aborting for this strategy", :highlight => :red
          next
        else
          Slh::Cli.instance.output "#{matching_hosts.map {|x| x.name}.join(',')} hosts matched in this strategy for filter #{@options[:filter]}", :highlight => :green
        end
      end

      # expose vars for ERB template
      @strategy = strategy 
      # @options is also exposed to utilize the --filter option

      File.open(File.join(strategy.config_dir,template_rel_file_path),'w') do |f|
        f.write(ERB.new(strategy.config_template_content(template_rel_file_path)).result(binding))
      end
      # strategy.hosts.each do |host|
      #   next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
      #   host_dir = strategy.config_dir_for_host(host)
      #   file_path = 'sp_metadata_for_host_to_give_to_idp.xml'
      #   @strategy = strategy
      #   @host = host
      #   # Global config shared across vhosts like the X509Certificate
      #   # uses the first site arbirarily
      #   @first_site_for_host = @host.sites.first
      #   Slh::Cli.instance.output "Generating metadata for #{host.name}"
      #   File.open(File.join(host_dir, file_path),'w') do |f|
      #     f.write(ERB.new(strategy.config_template_content(file_path)).result(binding))
      #   end
      # end
    end
  end
end
