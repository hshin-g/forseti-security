require 'json'
control 'Scanner' do

   describe yaml('/home/ubuntu/forseti-security/configs/forseti_conf_server.yaml') do
        its(['inventory', 'root_resource_id']) { should match /organizations\/230198968274/ }
   end

   describe "Run scanner" do

       before :context do
           command("forseti inventory purge 0").result
           command("forseti inventory create").result
           inventory_id = JSON.parse(command("forseti inventory list").stdout).fetch("id")
           command("forseti model create --inventory_index_id #{inventory_id} model_new").result
           command("forseti model use model_new").result
           unmodified_file = YAML.load_file('/home/ubuntu/forseti-security/configs/forseti_conf_server.yaml')
           modify_file = YAML.load_file('/home/ubuntu/forseti-security/configs/forseti_conf_server.yaml')
           modify_file['scanner', 'scanners', 1, 'enabled'] = "true"
           File.open('/home/ubuntu/forseti-security/configs/forseti_conf_server.yaml', 'w') {|f| f.write modify_file.to_yaml }
           command("forseti server configuration reload").result
       end

           it "should be visible from the command-line" do
               expect(command("forseti scanner run").stdout).to match /Running audit logging scanner/
           end


       after :context do
           File.open('/home/ubuntu/forseti-security/configs/forseti_conf_server.yaml', 'w') {|f| f.write unmodified_file.to_yaml }
           command("forseti server configuration reload").result
           command("forseti inventory purge 0").result
           command("forseti model delete model_new").result
       end
   end
end

