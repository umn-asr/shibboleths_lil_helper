class Slh::Models::Strategy
  attr_reader :name,:hosts
  def initialize(strategy_name,*args, &block)
    @name = strategy_name
    @hosts = []
    if block_given?
      self.instance_eval(&block)
    end
  end

  def for_host(host_name,*args,&block)
    @hosts << Slh::Models::Host.new(host_name,*args, &block)
  end

  def generate_config
    # generates the minimum XML configuration required for stuff to work
  end

  def config_file_dir
    if @config_file_dir.blank?
      @config_file_dir = Time.now.to_s.gsub(/[^A-Za-z0-9:-]/,'_') # Wed_Aug_10_15:54:06_-0500_2011
    end
    @config_file_dir
  end
end
