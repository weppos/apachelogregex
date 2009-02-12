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


require 'test_helper'


class ApacheLogRegexTest < Test::Unit::TestCase
  
  def setup
    @format = '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
    @parser = ApacheLogRegex.new(@format)
  end
  
  def test_regexp
    regexp = '(?-mix:^(\\S*) (\\S*) (\\S*) (\\[[^\\]]+\\]) (?-mix:"([^"\\\\]*(?:\\\\.[^"\\\\]*)*)") (\\S*) (\\S*) (?-mix:"([^"\\\\]*(?:\\\\.[^"\\\\]*)*)") (?-mix:"([^"\\\\]*(?:\\\\.[^"\\\\]*)*)")$)'
    assert_equal(regexp, @parser.regexp.to_s)
  end
  
  def test_parse_line
    expected = {  '%h'  => '212.74.15.68',
                  '%l'  => '-',
                  '%u'  => '-',
                  '%t'  => '[23/Jan/2004:11:36:20 +0000]',
                  '%r'  => 'GET /images/previous.png HTTP/1.1',
                  '%>s' => '200',
                  '%b'  => '2607',
                  '%{Referer}i'     => 'http://peterhi.dyndns.org/bandwidth/index.html',
                  '%{User-Agent}i'  => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2) Gecko/20021202' }
    results  = @parser.parse(read_testcase('line.log'))
    assert_kind_of(Hash, results)
    assert_match_expected_hash(expected, results)
  end
  
  def test_parse_line_with_slash_quote_in_request
    expected = {  '%h'  => '212.74.15.68',
                  '%l'  => '-',
                  '%u'  => '-',
                  '%t'  => '[23/Jan/2004:11:36:20 +0000]',
                  '%r'  => 'GET /images/previous.png=\" HTTP/1.1',
                  '%>s' => '200',
                  '%b'  => '2607',
                  '%{Referer}i'     => 'http://peterhi.dyndns.org/bandwidth/index.html',
                  '%{User-Agent}i'  => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2) Gecko/20021202' }
    results = @parser.parse(read_testcase('line-with-slash-quote-in-request.log'))
    assert_kind_of(Hash, results)
    assert_match_expected_hash(expected, results)
  end
  
  def test_parse_line_with_slash_quote_in_referer
    expected = {  '%h'  => '4.224.234.46',
                  '%l'  => '-',
                  '%u'  => '-',
                  '%t'  => '[20/Jul/2004:13:18:55 -0700]',
                  '%r'  => 'GET /core/listing/pl_boat_detail.jsp?&units=Feet&checked_boats=1176818&slim=broker&&hosturl=giffordmarine&&ywo=giffordmarine& HTTP/1.1',
                  '%>s' => '200',
                  '%b'  => '2888',
                  '%{Referer}i'     => 'http://search.yahoo.com/bin/search?p=\"grady%20white%20306%20bimini\"',
                  '%{User-Agent}i'  => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows 98; YPC 3.0.3; yplus 4.0.00d)' }
    results = @parser.parse(read_testcase('line-with-slash-quote-in-referer.log'))
    assert_kind_of(Hash, results)
    assert_match_expected_hash(expected, results)
  end
  
  def test_parse_line_returns_nil_on_invalid_format
    results = @parser.parse('foobar')
    assert_nil(results)
  end
  
  def test_parse_log
    results = File.open("#{TESTCASES_PATH}/log.log").readlines.map { |line| @parser.parse(line) }.compact # skip last line
    assert_equal(5, results.length)
    assert_equal(%w(87.18.183.252 79.28.16.191 79.28.16.191 69.150.40.169 217.220.110.75), results.map { |r| r['%h'] })
  end
  
  def test_stricparse_line
    testcase = read_testcase('line.log')
    assert_equal(@parser.parse(testcase), @parser.parse!(testcase))
  end
  
  def test_stricparse_line_raises_on_invalid_format
    error = assert_raise(ApacheLogRegex::ParseError) { results = @parser.parse!('foobar') }
    assert_match(/Invalid format/, error.message)
  end
  
  
  protected
  
    def read_testcase(filename)
      File.read("#{TESTCASES_PATH}/#{filename}")
    end
    
    def assert_match_expected_hash(expected, current)
      expected.each do |key, value|
        assert_equal(value, current[key], "Expected `#{key}` to match value `#{value}` but `#{current[:key]}`")
      end
    end

end
