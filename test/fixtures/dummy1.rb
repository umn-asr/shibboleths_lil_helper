Slh.define_entity_id :default, 'https://asr.umn.edu/shibboleth/default'
Slh.define_strategy :dummy1 do
  for_host 'shib-local-vm1.asr.umn.edu' do
    for_app 'https://shib-local-vm1.asr.umn.edu' do
      protect_location '/secure'
      protect_location '/lazy', :with => :lazy_authentication
    end
  end
end
