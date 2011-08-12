module Slh::ClassMethods
  @@strategies = []
  def strategies; @@strategies; end
  def define_strategy(strategy_sym, *args, &block)
    @@strategies << Slh::Models::Strategy.new(strategy_sym, *args, &block)
  end

  def with(strategy_sym)
    t = @@strategies.detect {|x| x.name == strategy_sym}
    raise "Unknown strategy #{t}" if t.blank?
    t
  end
end
