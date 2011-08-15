class Slh::Models::Base
  # Use this to set any string you might want to target in your templates
  # can be used to override existing object defaults
  #
  def set(inst_var, inst_val)
    raise "Must specify a symbol to this here .set method" unless inst_var.kind_of? Symbol
    inst_val = inst_val.to_s if inst_val.kind_of?(Symbol)
    if inst_val.kind_of?(String)
      self.instance_eval <<-EOS,__FILE__,__LINE__
        def #{inst_var}
          '#{inst_val}'
        end
      EOS
    elsif inst_val.kind_of? Proc
      raise "Not implemented, someone should add if this is needed"
    else
      raise "don't know how to set with a #{inst_val.class.to_s} typped object, u had #{inst_val}"
    end
  end
end
