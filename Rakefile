require 'rubygems'
require 'rake'

gem     'echoe', '>= 3.1'
require 'echoe'

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
require 'apache_log_regex'


# Common package properties
PKG_NAME    = ENV['PKG_NAME']    || ApacheLogRegex::GEM
PKG_VERSION = ENV['PKG_VERSION'] || ApacheLogRegex::VERSION
PKG_SUMMARY = "Ruby parser for Apache log files based on regular expressions."
PKG_FILES   = FileList.new("{lib,test}/**/*.rb") do |files|
  files.include %w(README.rdoc CHANGELOG.rdoc LICENSE.rdoc)
  files.include %w(Rakefile setup.rb)
end
RUBYFORGE_PROJECT = 'apachelogregex'
 
if ENV['SNAPSHOT'].to_i == 1
  PKG_VERSION << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end
 
 
Echoe.new(PKG_NAME, PKG_VERSION) do |p|
  p.author        = "Simone Carletti"
  p.email         = "weppos@weppos.net"
  p.summary       = PKG_SUMMARY
  p.description   = <<-EOF
    Apache Log Regex is a Ruby port \ 
    of Peter Hickman's Apache::LogRegex 1.4 Perl module. \
    It provides functionalities to parse a line from an Apache log file into a hash.
  EOF
  p.url           = "http://code.simonecarletti.com/apachelogregex"
  p.project       = RUBYFORGE_PROJECT

  p.need_zip      = true
  p.rcov_options  = ["-x Rakefile -x rcov"]
  p.rdoc_pattern  = /^(lib|CHANGELOG.rdoc|README.rdoc)/

  p.development_dependencies = ["rake  >=0.8",
                                "echoe >=3.1"]
end


begin
  require 'code_statistics'
  desc "Show library's code statistics"
  task :stats do
    CodeStatistics.new(["ApacheLogRegex", "lib"],
                       ["Tests", "test"]).to_s
  end
rescue LoadError
  puts "CodeStatistics (Rails) is not available"
end
