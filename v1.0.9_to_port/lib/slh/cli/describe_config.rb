class Slh::Cli::DescribeConfig < Slh::Cli::CommandBase
  def default_options
   { :mode => :all, :filter => :none}
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
      opts.on('-f','--filter FILTER', "Output will be filtered by matching hosts if specified") do |value|
        @options[:filter] = value
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
          next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
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
      warn_on_multiple_strategies = false
      host_strategy_mappings = {}
      Slh.strategies.each do |strategy|
        strategy.hosts.each do |host|
          next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
          host_strategy_mappings[host.name] ||= []
          host_strategy_mappings[host.name] << strategy
        end
      end
      host_strategy_mappings.each_pair do |host,strat_array|
        if strat_array.length > 1
          warn_on_multiple_strategies = true
          @output << [host, {:highlight => :red}]
        else
          @output << host
        end
        strat_array.each_with_index do |strat,index|
          @output << "    ---#{index+1}---"
          @output << "    strategy name: #{strat.name}"
          @output << "    sp_entity_id #{strat.sp_entity_id}"
          @output << "    idp_metadata_url #{strat.idp_metadata_url}"
        end
      end
      if warn_on_multiple_strategies
        @output << ["Make sure to check that the highlighted hosts with multiple strategies are configured correctly on your target hosts, only one can function correctly for a given host once deployed", {:highlight => :red}]
      end
    else
      raise "invalid mode #{@options[:mode]}"
    end
    @output.each do |line|
      if line.kind_of?(String) || line.kind_of?(Symbol)
        Slh::Cli.instance.output line.to_s
      elsif line.kind_of? Array
        Slh::Cli.instance.output line[0], line[1]
      end
    end
  end
end
