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


#
# = Apache Log Parser
#
# Parse a line from an Apache logfile into a hash.
#
# This is a port to python of Peter Hickman's Apache::LogEntry Perl module,
# available at http://cpan.uwinnipeg.ca/~peterhi/Apache-LogRegex .
#
class ApacheLogParser

  #
  # = ParseError
  #
  # Raised in case the parser can't parse a log line with current +format+.
  #
  class ParseError < RuntimeError; end


  # Log file format as provided on initialization
  attr_reader :format

  # Regexp instance used for parsing a log line
  attr_reader :regexp

  # Log fields' names
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
  # Same as <tt>ApacheLogParser#parse</tt> but raises a <tt>ParseError</tt>
  # if <tt>line</tt> doesn't match current <tt>format</tt>.
  #
  def parse!(line)
    parse(line) || raise(ParseError, "Invalid format `%s` for line `%s`" % [format, line])
  end

  def rename_this_name(name)
    name
  end

  
  protected

    # Parse log <tt>format</tt> into a suitable Regexp instance.
    def parse_format(format)
      f = format.to_s
      f.chomp!                # remove carriage return
      f.strip!                # remove leading and trailing space
      f.gsub!(/[ \t]+/, ' ')  # replace tabulations or spaces with a space

      find_quotes        = proc { |string| string =~ /^\\"/ } 
      find_referreragent = proc { |string| string =~ /Referer|User-Agent/ }
      find_percent       = proc { |string| string =~ /^%.*t$/ }
      strip_left_quotes  = proc { |string| string.gsub(/^\\"/, '') }
      strip_right_quotes = proc { |string| string.gsub(/\\"$/, '') }
      
      pattern = f.split(' ').map do |element|
        has_quotes = !!find_quotes.call(element)
        
        if has_quotes
          element = strip_left_quotes.call(element)
          element = strip_right_quotes.call(element)
        end

        self.names << rename_this_name(element)

        case
          when has_quotes
            if element == '%r' or find_referreragent.call(element)
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
    end

end
