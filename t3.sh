./bin/slh initialize -f --template_dir=umn.edu/oit-vms
./bin/slh generate
./bin/slh metadata

# YO CHRIS--UNCOMMENT THIS...
# FOR DEV with shibboleth_deployer, copy this regenerated config
# over to that repo
# rm -rf ../shibboleth_deployer/shibboleths_lil_helper
# cp -r shibboleths_lil_helper ../shibboleth_deployer/
