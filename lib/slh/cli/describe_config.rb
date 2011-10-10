class Slh::Cli::DescribeConfig < Slh::Cli::CommandBase
  def default_options
   { :mode => :all}
  end
  def option_parser
    @valid_modes = %w(all hosts)
    return OptionParser.new do |opts|
      opts.on('-m','--mode MODE', "Can be #{@valid_modes.join(',')}, extracts specified info from shibboleths_lil_helper/config.rb") do |value|
        unless @valid_modes.include?(value)
          raise "invalid mode option passed, #{value}"
        end
        @options[:mode] = value.to_sym
      end
    end
  end
 
  def perform_action
    @output = [] 
    case @options[:mode]
    when :all
      Slh.strategies.each do |strategy|
        @output << strategy.name
        strategy.hosts.each do |host|
          @output << "  #{host.name} #{host.host_type}"
          host.sites.each do |site|
            @output << "    #{site.name}"
            site.paths.each do |path|
              @output << "      #{path.name} #{path.flavor}"
            end
          end
        end
      end
    when :hosts
      host_strategy_mappings = {}
      Slh.strategies.each do |strategy|
        strategy.hosts.each do |host|
          host_strategy_mappings[host.name] ||= []
          host_strategy_mappings[host.name] << strategy
        end
      end
      host_strategy_mappings.each_pair do |host,strat_array|
        @output << host
        strat_array.each_with_index do |strat,index|
          @output << "    ---#{index+1}---"
          @output << "    strategy name: #{strat.name}"
          @output << "    sp_entity_id #{strat.sp_entity_id}"
          @output << "    idp_metadata_url #{strat.idp_metadata_url}"
        end
      end
    else
      raise "invalid mode #{@options[:mode]}"
    end
    Slh::Cli.instance.output @output.join("\n")
  end
end
