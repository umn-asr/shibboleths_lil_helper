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
end
