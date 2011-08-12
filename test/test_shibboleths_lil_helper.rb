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
    # TODO add more
  end

  context "with :dummy1 strategy" do
    setup do
      require 'fixtures/dummy1.rb'
      @strategy = Slh.with(:dummy1)
    end
    teardown do
      FileUtils.rm_rf(@strategy.config_dir)
    end
    should "have an entity id" do
      assert_equal "https://shib-local-vm1.asr.umn.edu/rhel5_sp1", @strategy.sp_entity_id
      assert_raises RuntimeError do
        Slh::Models::Strategy.new(:poo) # Must specify a :sp_entity_id and idp_entity_id
      end
    end
    should "have an idp_metadata_url" do
      assert_equal "https://idp-test.shib.umn.edu/metadata.xml", @strategy.idp_metadata_url
    end
    should "have an idp_entity_id extracted from the idp_metadata_url contents" do
      # WARNING: THIS CODE IS BRITTLE AND CODED AGAINST an XML format returned from https://idp-test.shib.umn.edu/metadata.xml
      assert_equal "https://idp-test.shib.umn.edu/idp/shibboleth", @strategy.idp_entity_id
    end
    should "have an error_support_contact" do
      assert_equal "goggins@umn.edu", @strategy.error_support_contact
    end
    should "load up a strategy" do
      assert_kind_of Slh::Models::Strategy, @strategy
      assert_raises RuntimeError do 
        Slh.with(:asldfjlaksdjflk)
      end
    end
    should "have a non-empty hosts array" do
      assert_kind_of Array, @strategy.hosts
      assert @strategy.hosts.length > 0, 'more than 1 host in the array'
      assert @strategy.hosts.first.name == 'shib-local-vm1.asr.umn.edu'
    end
    should "have a non-empty apps array for the first host" do
      assert_kind_of Array, @strategy.hosts.first.apps
      assert @strategy.hosts.first.apps.length > 0
      assert @strategy.hosts.first.apps.first.url == 'https://shib-local-vm1.asr.umn.edu'
    end
    should "have non-empty app_auth_rules array for first host and first app" do
      assert_kind_of Array, @strategy.hosts.first.apps.first.auth_rules

      # First auth rule
      assert @strategy.hosts.first.apps.first.auth_rules.first.url_path == '/secure'
      assert @strategy.hosts.first.apps.first.auth_rules.first.rule_type == :location
      assert @strategy.hosts.first.apps.first.auth_rules.first.flavor == :mandatory_authentication

      # Second auth rule
      assert @strategy.hosts.first.apps.first.auth_rules[1].url_path == '/lazy'
      assert @strategy.hosts.first.apps.first.auth_rules[1].rule_type == :location
      assert @strategy.hosts.first.apps.first.auth_rules[1].flavor == :lazy_authentication
    end

    should "generate a config dir" do
      @strategy.generate_config
      assert File.directory?(@strategy.config_dir)
    end

    should "generate a shibboleth2.xml" do
      @strategy.generate_config
      assert File.exists?(@strategy.config_file_path('shibboleth2.xml'))
      expected_content = File.read(File.join(File.dirname(__FILE__),'fixtures','dummy1_output/shibboleth2.xml'))
      actual_content = File.read(@strategy.config_file_path('shibboleth2.xml'))
      assert_equal expected_content, actual_content
    end

    should "write the idp_metadata gathered from the idp_metadata_url to a file" do
      @strategy.generate_config
      assert File.exists?(@strategy.config_file_path('idp_metadata.xml'))
      assert_equal @strategy.idp_metadata, File.read(@strategy.config_file_path('idp_metadata.xml'))
    end

    should "generate the attribute-map.xml" do
      @strategy.generate_config
      assert File.exists?(@strategy.config_file_path('attribute-map.xml'))
      expected_content = File.read(File.join(File.dirname(__FILE__),'fixtures','dummy1_output/attribute-map.xml'))
      actual_content = File.read(@strategy.config_file_path('attribute-map.xml'))
      assert_equal expected_content, actual_content
    end

    should "generate shib_for_vhost.conf for each host and app" do
      @strategy.generate_config
      assert File.exists?(@strategy.config_file_path('shib_for_vhost.conf'))
      expected_content = File.read(File.join(File.dirname(__FILE__),'fixtures','dummy1_output/shib_for_vhost.conf'))
      actual_content = File.read(@strategy.config_file_path('shib_for_vhost.conf'))
      assert_equal expected_content, actual_content
    end
  end
end
