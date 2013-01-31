#
# Cookbook Name:: coldfusion10
# Library:: cf10entmanger
#
# Copyright 2013, Nathan Mische
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Chef::Recipe::CF10Entmanager 

    def self.get_instance_data(instance, node)

      require "rexml/document"

      # Find the instance in the ColdFuison server's instances.xml
      instances_xml_doc = REXML::Document.new ::File.new("#{node['cf10']['installer']['install_folder']}/config/instances.xml")
      server_xml_element = instances_xml_doc.elements["//*/text()[normalize-space(.)='#{instance}']/../.."]
      Chef::Application.fatal!("No instance named #{instance} found.") unless server_xml_element

      # Find the HTTP port from the instance's server.xml
      instance_dir = server_xml_element.elements["directory"].text.strip
      server_xml_doc = REXML::Document.new ::File.new("#{instance_dir}/runtime/conf/server.xml")
      http_connector_xml_element = server_xml_doc.root.elements["//Connector[@protocol='org.apache.coyote.http11.Http11Protocol']"]
      Chef::Application.fatal!("The #{new_resource.instance} instance does not appear to be running an HTTP connector.") unless http_connector_xml_element

      port = http_connector_xml_element.attributes["port"]

      instance_data = Hash.new()
      instance_data["instance_dir"] = instance_dir
      instance_data["http_port"] = port
      instance_data["cfide_dir"] = "#{instance_dir}/wwwroot/CFIDE"
      instance_data["lib_dir"] = "#{instance_dir}/lib"
      instance_data["api_path"] = "http://localhost:#{port}/CFIDE/administrator/configmanager/api"

      instance_data
        
    end

end