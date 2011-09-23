module Slh::ClassMethods
  @@strategies = []
  def strategies; @@strategies; end
  def for_strategy(strategy_sym, *args, &block)
    @@strategies << Slh::Models::Strategy.new(strategy_sym, *args, &block)
  end

  def config_dir
    'shibboleths_lil_helper'
  end

  def config_file
    File.join self.config_dir,'config.rb'
  end

  @@is_loaded = false
  def load_config
    unless @@is_loaded 
      Slh::Cli.instance.output "Loading #{Slh.config_file}"
      require Slh.config_file
      if Slh.strategies.empty?
        Slh::Cli.instance.output "No strategies found in #{Slh.config_file}, you should add some, exiting...",
          :highlight => :red,
          :exit => true
      end
      @is_loaded = true
    end
  end
end
