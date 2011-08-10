require 'helper'

class TestShibbolethsLilHelper < Test::Unit::TestCase
  should "have a Slh namespace that will contain all classes contained" do
    assert Slh.class == Module
  end
  should "provides class representing core shibboleth model-ish ideas" do
    assert Slh::Models::App.class == Class
    assert Slh::Models::Host.class == Class
    # TODO add more
  end
  should "provide some top level methods for using the tool" do
    assert_respond_to Slh, :define_entity_id
    # TODO add more
  end

  context "with strategy DSL for :dummy1" do
    setup do
      require 'fixtures/dummy1.rb'
    end
    should "have an entity id" do
      assert_kind_of String, Slh.entity_id(:default) 
      #Slh.with(:dummy1).generate_config
    end
    should "load up a strategy" do
      assert_kind_of Slh::Models::Strategy, Slh.with(:dummy1)
    end
  end
end
