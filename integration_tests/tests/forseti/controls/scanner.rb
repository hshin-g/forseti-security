require 'json'
control 'Scanner' do

   describe yaml('/home/ubuntu/forseti-security/configs/forseti_conf_server.yaml') do
        before :context do
            puts "Present working directory:", Dir.pwd
        end

        its(['inventory', 'root_resource_id']) { should match /organizations\/230198968274/ }
   end

   describe "Run scanner" do

       before :context do
           puts "Present working directory:", Dir.pwd
           command("forseti inventory purge 0").result
           command("forseti inventory create").result
           inventory_id = JSON.parse(command("forseti inventory list").stdout).fetch("id")
           command("forseti model create --inventory_index_id #{inventory_id} model_new").result
           command("forseti model use model_new").result
           unmodified_yaml = yaml('/home/ubuntu/forseti-security/configs/forseti_conf_server.yaml').params
           modified_yaml = yaml('/home/ubuntu/forseti-security/configs/forseti_conf_server.yaml').params
           modified_yaml["scanner"]["scanners"][1]["enable"] = "true"
           command("echo #{modified_yaml} > /home/ubuntu/forseti-security/configs/forseti_conf_server.yaml").result
           # command("echo cat #{modified_yaml}")
           command("head -10 #{modified_yaml}")
           command("forseti server configuration reload").result
       end

           it "should be visible from the command-line" do
               expect(command("forseti scanner run").stdout).to match /Scan completed/
           end


       after :context do
           command("echo #{unmodified_yaml} > /home/ubuntu/forseti-security/configs/forseti_conf_server.yaml")
           command("forseti server configuration reload").result
           command("forseti inventory purge 0").result
           command("forseti model delete model_new").result
       end
   end
end

