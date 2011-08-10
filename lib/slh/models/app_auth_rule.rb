class Slh::Models::AppAuthRule
  attr_reader :url_path, :rule_type, :flavor
  VALID_FLAVORS = [:mandatory_authentication, :lazy_authentication]
  VALID_RULE_TYPES = [:location] # TODO, could be dir or file corresponding to Apache directives
  def initialize(url_path,rule_type,*args, &block)
    @url_path = url_path
    @rule_type = rule_type
    options = args.extract_options!
    if options[:with].blank?
      @flavor = :mandatory_authentication
    else
      unless VALID_FLAVORS.include?(options[:with])
        raise "Invalid flavored auth rule, u had #{options[:with]}, must be one of #{VALID_FLAVORS.join(',')}"
      end
      @flavor = options[:with]
    end
    if block_given?
      raise "Not sure what might happen here...or if its necessary"
    end
  end
end
