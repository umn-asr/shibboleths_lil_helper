# Slh.define_entity_id :default, 'https://shib-local-vm1.asr.umn.edu/rhel5_sp1'
# Slh.define_idp_meta_data :default, 'https://idp-test.shib.umn.edu/metadata.xml'
# Slh.define_error_support_contact :default, 'goggins@umn.edu'
#
Slh.for_strategy :dummy1,
  :sp_entity_id => 'https://shib-local-vm1.asr.umn.edu/rhel5_sp1',
  :idp_metadata_url => 'https://idp-test.shib.umn.edu/metadata.xml',
  :error_support_contact => 'goggins@umn.edu' do
  for_host 'shib-local-vm1.asr.umn.edu' do
    for_site 'https://shib-local-vm1.asr.umn.edu' do
      protect '/secure'
      protect '/lazy', :flavor => :authentication_optional
    end
  end
end
