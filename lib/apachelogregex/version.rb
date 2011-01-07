#
# = Apache Log Regex
#
# Ruby parser for Apache log files based on regular expressions.
#
# Category::    
# Package::     ApacheLogRegex
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
# SVN: $Id$
#++


class ApacheLogRegex
  
  module Version #:nodoc:
    MAJOR = 0
    MINOR = 1
    TINY  = 2
    
    STRING = [MAJOR, MINOR, TINY].join('.')
  end
  
  VERSION         = Version::STRING
  STATUS          = 'alpha'
  BUILD           = ''.match(/(\d+)/).to_a.first
  
end
