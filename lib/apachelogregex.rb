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


require 'lib/apachelogregex/version'


#
# = Apache Log Regex
#
# Parse a line from an Apache log file into a hash.
#
# This is a Ruby port of Peter Hickman's Apache::LogRegex 1.4 Perl module,
# available at http://cpan.uwinnipeg.ca/~peterhi/Apache-LogRegex.
# 
# == Example Usage
# 
# The following one is the most simple example usage. 
# It tries to parse the `access.log` file and echoes each parsed line.
# 
#   format = '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
#   parser = ApacheLogRegex.new(format)
#   
#   File.foreach('/var/apache/access.log') do |line|
#     parser.parse(line)
#     # {"%r"=>"GET /blog/index.xml HTTP/1.1", "%h"=>"87.18.183.252", ... }
#   end
# 
# More often, you might want to collect parsed lines and use them later in your program.
# The following example iterates all log lines, parses them and returns an array of Hash with the results.
# 
#   format = '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
#   parser = ApacheLogRegex.new(format)
# 
#   File.readlines('/var/apache/access.log').collect do |line|
#     parser.parse(line)
#     # {"%r"=>"GET /blog/index.xml HTTP/1.1", "%h"=>"87.18.183.252", ... }
#   end
# 
# If you want more control over the parser you can use the <tt>parse!</tt> method. 
# It raises a <tt>ParseError</tt> if given line doesn't match the log format.
# 
#   common_log_format = '%h %l %u %t \"%r\" %>s %b'
#   parser = ApacheLogRegex.new(common_log_format)
#   
#   # No exception
#   parser.parse(line) # => nil
#   
#   # Raises an exception
#   parser.parse!(line) # => ParseError
# 
class ApacheLogRegex
  
  NAME            = 'ApacheLogRegex'
  GEM             = 'apachelogregex'
  AUTHOR          = 'Simone Carletti <weppos@weppos.net>'
  
  
  #
  # = ParseError
  #
  # Raised in case the parser can't parse a log line with current +format+.
  #
  class ParseError < RuntimeError; end
  
  
  # The normalized log file format.
  # Some common formats:
  # 
  #   Common Log Format (CLF)
  #   '%h %l %u %t \"%r\" %>s %b'
  # 
  #   Common Log Format with Virtual Host
  #   '%v %h %l %u %t \"%r\" %>s %b'
  # 
  #   NCSA extended/combined log format
  #   '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"'
  # 
  attr_reader :format

  # Regexp instance used for parsing a log line.
  attr_reader :regexp

  # The list of field names that extracted from log format.
  attr_reader :names


  # Initializes a new parser instance with given log <tt>format</tt>.
  def initialize(format)
    @regexp = nil
    @names  = []
    @format = parse_format(format)
  end

  # Parses <tt>line</tt> according to current log <tt>format</tt>
  # and returns an hash of log field => value on success.
  # Returns <tt>nil</tt> if <tt>line</tt> doesn't match current log <tt>format</tt>.
  def parse(line)
    row = line.to_s
    row.chomp!
    row.strip!
    return unless match = regexp.match(row)

    data = {}
    names.each_with_index { |field, index| data[field] = match[index + 1] } # [0] == line
    data
  end

  # Same as <tt>ApacheLogRegex#parse</tt> but raises a <tt>ParseError</tt>
  # if <tt>line</tt> doesn't match current <tt>format</tt>.
  # 
  # ==== Raises
  # 
  # ParseError:: if <tt>line</tt> doesn't match current <tt>format</tt>
  # 
  def parse!(line)
    parse(line) || raise(ParseError, "Invalid format `%s` for line `%s`" % [format, line])
  end
  
  
  protected
    
    # Overwrite this method if you want to use some human-readable name for log fields.
    # This method is called only once at <tt>parse_format</tt> time.
    def rename_this_name(name)
      name
    end

    # Parse log <tt>format</tt> into a suitable Regexp instance.
    def parse_format(format)
      format = format.to_s
      format.chomp!                # remove carriage return
      format.strip!                # remove leading and trailing space
      format.gsub!(/[ \t]+/, ' ')  # replace tabulations or spaces with a space

      strip_quotes = proc { |string| string.gsub(/^\\"/, '').gsub(/\\"$/, '') }
      find_quotes  = proc { |string| string =~ /^\\"/ } 
      find_percent = proc { |string| string =~ /^%.*t$/ }
      find_referrer_or_useragent = proc { |string| string =~ /Referer|User-Agent/ }
      
      pattern = format.split(' ').map do |element|
        has_quotes = !!find_quotes.call(element)
        element = strip_quotes.call(element) if has_quotes
        
        self.names << rename_this_name(element)

        case
          when has_quotes
            if element == '%r' or find_referrer_or_useragent.call(element)
              /"([^"\\]*(?:\\.[^"\\]*)*)"/
            else
              '\"([^\"]*)\"'
            end
          when find_percent.call(element)
              '(\[[^\]]+\])'
          when element == '%U'
              '(.+?)'
          else
              '(\S*)'
        end
      end.join(' ')

      @regexp = Regexp.new("^#{pattern}$")
      format
    end

end
