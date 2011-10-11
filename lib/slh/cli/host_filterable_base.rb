# An abstract class shared by generators that filter by host
# Generators that loop over hosts and want to support this form of filtering might consider
# extending from this class and use this code in their host iterator
#   next if @options[:filter].kind_of?(String) && !host.name.match(@options[:filter])
class Slh::Cli::HostFilterableBase < Slh::Cli::CommandBase
  def default_options
   {:filter => :none}
  end
  def option_parser
    return OptionParser.new do |opts|
      opts.on('-f','--filter FILTER', "Output will be filtered by matching hosts if specified") do |value|
        @options[:filter] = value
      end
    end
  end
end
