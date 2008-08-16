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


require  File.dirname(__FILE__) + '/helper'
Dir.glob(File.dirname(__FILE__) + '/unit/**/*_test.rb').sort.each { |unit| require unit }
