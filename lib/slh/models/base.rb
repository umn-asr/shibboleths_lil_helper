class Slh::Models::Base
  def set(attr_accessor_name, val)
    self.send("#{attr_accessor_name}=",val)
  end
  # Use this to set any string you might want to target in your templates
  # can be used to override existing object defaults
  #
  # TODO reimplement as set_custom
  # def set(inst_var, inst_val)
  #   raise "Must specify a symbol to this here .set method" unless inst_var.kind_of? Symbol
  #   # We assume if a getter exists already for inst_var, then
  #   # simply setting the inst var will suffice
  #   if self.respond_to? inst_var
  #     self.instance_variable_set("@#{inst_var.to_s}".to_sym, inst_val)
  #   else
  #     raise "Doing this kinda meta-data crazy can currently only accept strings" unless inst_val.kind_of? String
  #     if inst_val.kind_of?(String)
  #       unless self.respond_to?(inst_var)
  #         Slh::Cli.instance.output "WARNING: call to .set references an unknown piece of info (#{inst_var}) not referenced in the default templates, you should ignore this warning only if you are overriding the templates"
  #       end
  #       self.instance_eval <<-EOS,__FILE__,__LINE__
  #         def #{inst_var}
  #           '#{inst_val}'
  #         end
  #       EOS
  #     elsif inst_val.kind_of? Proc
  #       raise "Not implemented, someone should add if this is needed"
  #     else
  #       raise "don't know how to set with a #{inst_val.class.to_s} typped object, u had #{inst_val}"
  #     end
  #   end
  # end
end
