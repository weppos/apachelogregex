#
# = Apache Log Parser
#
# Parser for Apache log files based on regular expressions.
#
# Category::   
# Package::    ApacheLogParser
# Author::     Simone Carletti <weppos@weppos.net>
#
#--
# SVN: $Id$
#++


require  File.dirname(__FILE__) + '/helper'
Dir.glob(File.dirname(__FILE__) + '/unit/**/*_test.rb').sort.each { |unit| require unit }
