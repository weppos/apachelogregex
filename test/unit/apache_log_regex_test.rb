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


require File.dirname(__FILE__) + '/../helper'


class ApacheLogRegexTest < Test::Unit::TestCase
  
  def setup
    @format = '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
    @regexp = '(?-mix:^(\\S*) (\\S*) (\\S*) (\\[[^\\]]+\\]) (?-mix:"([^"\\\\]*(?:\\\\.[^"\\\\]*)*)") (\\S*) (\\S*) (?-mix:"([^"\\\\]*(?:\\\\.[^"\\\\]*)*)") (?-mix:"([^"\\\\]*(?:\\\\.[^"\\\\]*)*)")$)'

    @line1  = '212.74.15.68 - - [23/Jan/2004:11:36:20 +0000] "GET /images/previous.png HTTP/1.1" 200 2607 "http://peterhi.dyndns.org/bandwidth/index.html" "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2) Gecko/20021202"'
    @line2  = '212.74.15.68 - - [23/Jan/2004:11:36:20 +0000] "GET /images/previous.png=\" HTTP/1.1" 200 2607 "http://peterhi.dyndns.org/bandwidth/index.html" "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2) Gecko/20021202"'
    @line3  = '4.224.234.46 - - [20/Jul/2004:13:18:55 -0700] "GET /core/listing/pl_boat_detail.jsp?&units=Feet&checked_boats=1176818&slim=broker&&hosturl=giffordmarine&&ywo=giffordmarine& HTTP/1.1" 200 2888 "http://search.yahoo.com/bin/search?p=\"grady%20white%20306%20bimini\"" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98; YPC 3.0.3; yplus 4.0.00d)"'
    @parser = ApacheLogRegex.new(@format)
  end
  
  def test_regexp
    assert_equal(@regexp, @parser.regexp.to_s)
  end
  
  def test_line_1
    results = @parser.parse(@line1)
    assert_kind_of(Hash, results)
  end
  
  def test_line_2
    results = @parser.parse(@line1)
    assert_kind_of(Hash, results)
  end
  
  def test_line_3
    results = @parser.parse(@line3)
    assert_kind_of(Hash, results)
  end

end
