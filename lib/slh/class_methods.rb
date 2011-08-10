module Slh::ClassMethods
  @@entity_ids = {}
  def define_entity_id(sym,string)
    @@entity_ids[sym] = string
  end
  def entity_id(sym)
    raise "No entity_id set for :#{sym}" unless @@entity_ids.has_key?(sym)
    @@entity_ids[sym]
  end

  @@strategies = []
  def define_strategy(strategy_sym, &block)
    @@strategies << Slh::Models::Strategy.new(strategy_sym)
  end
  def with(strategy_sym)
    t = @@strategies.detect {|x| x.name == strategy_sym}
    raise "Unknown strategy #{t}" if t.blank?
    t
  end
end
