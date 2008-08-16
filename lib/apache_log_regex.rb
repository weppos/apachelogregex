#
# = Apache Log Regex
#
# Ruby parser for Apache log files based on regular expressions.
#
# Category::   
# Package::    ApacheLogRegex
# Author::     Simone Carletti <weppos@weppos.net>
#
#--
# SVN: $Id$
#++


require 'apache_log_regex/version'


#
# = Apache Log Regex
#
# Parse a line from an Apache logfile into a hash.
#
# This is a Ruby port of Peter Hickman's Apache::LogRegex 1.4 Perl module,
# available at http://cpan.uwinnipeg.ca/~peterhi/Apache-LogRegex.
#
class ApacheLogRegex
  
  NAME            = 'ApacheLogRegex'
  GEM             = 'apachelogregex'
  AUTHOR          = 'Simone Carletti <weppos@weppos.net>'
  VERSION         = defined?(Version) ? Version::STRING : nil
  STATUS          = 'alpha'
  BUILD           = ''.match(/(\d+)/).to_a.first
  
  
  #
  # = ParseError
  #
  # Raised in case the parser can't parse a log line with current +format+.
  #
  class ParseError < RuntimeError; end
  
  
  # The normalized log file format.
  attr_reader :format

  # Regexp instance used for parsing a log line.
  attr_reader :regexp

  # The list of field names that extracted from log format.
  attr_reader :names


  #
  # Initializes a new parser instance with given log <tt>format</tt>.
  #
  def initialize(format)
    @regexp = nil
    @names  = []
    @format = parse_format(format)
  end

  #
  # Parses <tt>line</tt> according to current log <tt>format</tt>
  # and returns an hash of log field => value on success.
  # Returns <tt>nil</tt> if <tt>line</tt> doesn't match current log <tt>format</tt>.
  #
  def parse(line)
    row = line.to_s.chomp
    return unless match = regexp.match(row)

    data = {}
    names.zip(match.to_a) { |field, value| data[field] = value }
    data
  end

  #
  # Same as <tt>ApacheLogRegex#parse</tt> but raises a <tt>ParseError</tt>
  # if <tt>line</tt> doesn't match current <tt>format</tt>.
  #
  def parse!(line)
    parse(line) || raise(ParseError, "Invalid format `%s` for line `%s`" % [format, line])
  end
  
  protected
    
    # 
    # Overwrite this method if you want to use some human-readable name
    # for log fields.
    # This method is called only once at <tt>parse_format</tt> time.
    #
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
