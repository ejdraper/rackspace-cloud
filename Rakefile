require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require File.join(File.dirname(__FILE__), "lib", "rackspace-cloud")

Hoe.plugin :newgem

$hoe = Hoe.spec 'rackspace-cloud' do
  self.developer 'Elliott Draper', 'el@ejdraper.com'
  self.post_install_message = 'PostInstall.txt'
  self.rubyforge_name       = self.name
  self.extra_deps         = [['rest-client','>= 1.0.3'], ['activesupport','>= 2.3.4']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }
