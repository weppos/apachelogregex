#!/usr/bin/env ruby

class LogGenerator
  
  # 
  # = Error
  #
  # Generic Error, base class for all specific errors.
  #
  class Error < RuntimeError; end
  
  # Array of log templates to be used for generating the log.
  # Each template can be either a Proc or a String.
  attr_accessor :templates
  
  @@filename_counter = 0
  
  
  def initialize
    @templates = []
    @log_queue = []
    @log_files = []
  end
  
  def run
    ensure_has_templates!
    return unless logs?
    
    begin
      prepare_log_queue!
      prepare_log_files!
      process_queue!
    ensure # close all streams on error
      @log_files.each { |f| f.close }
    end
  end

  def templates?
    !templates.empty?
  end
  
  def logs?
    !@log_queue.empty?
  end
  
  # Queue a new request for a log with +nof_lines+ lines. 
  def queue_log(nof_lines)
    raise ArgumentError, 'Invalid `nof_lines`' unless nof_lines.respond_to? :to_i
    @log_queue << nof_lines.to_i
  end
  
  protected
  
    # Ensures current log generator has at least one template.
    def ensure_has_templates!
      raise Error, 'You need at least one line template' unless templates?
    end
  
    # Returns a random log line generated from one of available +templates+.
    # If template is a Proc then the Proc is called else it simply returns the template as a string.
    def random_line
      index    = rand(templates.length * 1000) % templates.length
      template = templates.at(index)
      case 
        when template.kind_of?(Proc)
          template.call
        when template.respond_to?(:to_s)
          template.to_s
      else
        raise Error, "Invalid template class `#{template.class}` at index `#{index}`"
      end
    end
    
    # Returns an unique filename for a log in queue.
    def unique_filename(nof_lines)
      "#{next_filename_counter}_at_#{Time.now.to_i.to_s}_with_#{nof_lines}_lines.log"
    end
    
    # Prepare and sort log queue.
    def prepare_log_queue!
      @log_queue.sort!
    end
    
    # Prepare log file pointers for each log in queue.
    def prepare_log_files!
      @log_queue.each do |log_size| 
        @log_files << File.open(unique_filename(log_size), 'w+')
      end
    end
    
    def process_queue!
      1.upto(max_nof_lines) do |line_number|
        write_line_to_all_files(random_line)
        discard_completed_files(line_number)
      end
    end
    
    # Writes +line+ to all file.
    def write_line_to_all_files(line)
      @log_files.each { |f| f.puts(line) }
    end
    
    def discard_completed_files(line_number)
      return if @log_queue.first > line_number
      
      end_of_range  = 0
      end_of_range += 1 until end_of_range < @log_queue.length and @log_queue[end_of_range] <= line_number
      range = Range.new(0, end_of_range)
      
      log_queue = @log_queue.slice!(range)
      log_files = @log_files.slice!(range)
      log_files.each { |f| f.close }
    end
    
    # Returns the max number of log lines to be created. 
    def max_nof_lines
      @log_queue.last
    end
    
    def next_filename_counter
      @@filename_counter += 1
    end
  
end

start = Time.now
lg = LogGenerator.new
lg.templates << proc { '87.5.116.175 - - [13/Aug/2008:00:55:11 -0700] "GET /blog/styles-site.css HTTP/1.1" 200 1959 "http://www.simonecarletti.com/blog/2007/11/crash-di-ical-ad-ogni-avvio.php" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; it; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1" '  }
lg.templates << proc { '79.31.96.106 - - [13/Aug/2008:01:01:20 -0700] "GET /blog/public/2007/03/strumenti-sviluppo-subversion-svn/svn-simplepie.png HTTP/1.1" 200 2958 "http://www.simonecarletti.com/blog/2007/03/strumenti-sviluppo-subversion-svn.php" "Mozilla/5.0 (Windows; U; Windows NT 5.1; it; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1" '  }
%w(5000 10000 50000 100000 500000 1000000).each { |i| lg.queue_log(i.to_i) }
lg.run
puts (Time.now - start).to_s + ' seconds'