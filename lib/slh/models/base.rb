class Slh::Models::Base
  def set(attr_accessor_name, val)
    self.send("#{attr_accessor_name}=",val)
  end

  # A wee-bit-o-meta-programming to dynamically create stuff you might want to expose
  # and interpolate in templates
  # http://blog.jayfields.com/2008/02/ruby-dynamically-define-method.html
  # Allows stuff like
  #   # in config.rb
  #   set_custom :poo,'the_poo'
  #   # in a template
  #   <%= @strategy.poo -%>  ---> will return "the_poo"
  #
  def set_custom(attr_accessor_name,val)
    (class << self; self; end).class_eval do
      define_method attr_accessor_name do
        val
      end
    end
    return true
  end
end
