#
# = Apache Log Regex
#
# Ruby parser for Apache log files based on regular expressions.
#
# Category::    
# Package::     ApacheLogRegex
# Author::      Simone Carletti <weppos@weppos.net>
# License::     
#
#--
# SVN: $Id$
#++


# prepend lib folder
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'apache_log_regex'

# testcase file path
TESTCASES_PATH   = File.dirname(__FILE__) + '/testcases' unless defined?(TESTCASES_PATH)
FIXTURES_PATH    = File.dirname(__FILE__) + '/fixtures'  unless defined?(FIXTURES_PATH)
