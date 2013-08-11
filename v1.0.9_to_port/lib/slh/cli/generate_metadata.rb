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
      else
        matching_hosts = strategy.hosts
      end

      # expose vars for ERB template
      @strategy = strategy 
      @matching_hosts = matching_hosts
      # @options is also exposed to utilize the --filter option

      file_path = File.join(strategy.config_dir,"#{strategy.name}_sp_metadata_for_idp.xml")
      File.open(file_path,'w') do |f|
        f.write(ERB.new(strategy.config_template_content(template_rel_file_path)).result(binding))
        Slh::Cli::instance.output "Wrote metadata to\n  #{file_path}"
      end
    end
  end
end
