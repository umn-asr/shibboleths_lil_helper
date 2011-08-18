class Slh::Models::SitePath < Slh::Models::Base
  attr_reader :name
  attr_accessor :flavor,
    :specific_users # for usage when the flavor is :authentication_required_for_specific_users
  def initialize(site_path,*args, &block)
    @name = site_path
    @flavor = :authentication_required
    @specific_users = []
    options = args.extract_options!
    if block_given?
      self.instance_eval(&block)
    end
  end
end
