class Slh::Models::SitePath < Slh::Models::Base
  attr_reader :name, :parent_site
  attr_accessor :flavor,
    :specific_users # for usage when the flavor is :authentication_required_for_specific_users
  def initialize(site_path,parent_site,&block)
    @parent_site = parent_site
    if site_path.match(/^\/.+/)
      raise "Invalid site path: #{site_path}, leading slashes are NOT allowed except when protecting an entire site"
    end
    @name = site_path
    @flavor = :authentication_required
    @specific_users = []
    if block_given?
      self.instance_eval(&block)
    end
  end
end
