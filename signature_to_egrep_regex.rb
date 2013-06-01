#!/usr/bin/env ruby

require 'erb'

IP_ADDRESS                 = '\b(?:[012]?\d?\d\.){3}[012]?\d?\d\b'
TS_SYSLOG                  = '(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [ 0123][0-9] \d\d:\d\d:\d\d'
TS_SYSLOG_WITH_WEEKDAY     = '(?:Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s+' + TS_SYSLOG
SYSLOG_PREFIX              = TS_SYSLOG + ' \S+ \S+(?:\[\d+\])?: '
ISODATE                    = '\d\d\d\d-\d\d-\d\d[ T]\d\d:\d\d:\d\d'
ISODATE_WITH_USEC          = '\d\d\d\d-\d\d-\d\d[ T]\d\d:\d\d:\d\d.\d\d\d\d\d\d'
RN_LOG_PREFIX              = ISODATE_WITH_USEC + '\s+\d+\s+(DEBUG|WARNING|NOTICE|INFO|CRITICAL|ERROR) -- \d+\s+\| '
HEXNUM                     = '[A-Fa-f0-9][A-Fa-f0-9]+'
FLOAT                      = '[\-+]?\d+\.\d+(?:[eE][\-+]?\d+)?'
INTEGER                    = '[\-+]?\d+'
REGEX_SPECIAL_CHAR         = '[\+\{\}\(\)\[\]\$\^\?\\\\\*\`]'
FULL_FILE_PATH             = '(?:/[^/]+)+/?'
RUBY_STACK_TRACE_FILE_LINE = FULL_FILE_PATH + ':\d+:in `\S+' + "\'`"
WHITESPACE_REGION          = '\s+\s'

STDIN.lines.each do |line|
  line.chomp!
  # Find datestamp if any and replace it
  line.gsub!(/#{RN_LOG_PREFIX}/              , '<%= RN_LOG_PREFIX %>')
  line.gsub!(/#{ISODATE_WITH_USEC}/          , '<%= ISODATE_WITH_USEC %>')
  line.gsub!(/#{SYSLOG_PREFIX}/              , '<%= SYSLOG_PREFIX %>')
  line.gsub!(/#{TS_SYSLOG_WITH_WEEKDAY}/     , '<%= TS_SYSLOG_WITH_WEEKDAY %>')
  line.gsub!(/#{TS_SYSLOG}/                  , '<%= TS_SYSLOG %>')
  line.gsub!(/#{IP_ADDRESS}/                 , '<%= IP_ADDRESS %>')
  line.gsub!(/#{ISODATE}/                    , '<%= ISODATE %>')
  line.gsub!(/#{FLOAT}/                      , '<%= FLOAT %>')
  line.gsub!(/#{INTEGER}/                    , '<%= INTEGER %>')
  line.gsub!(/#{FULL_FILE_PATH}/             , '<%= FULL_FILE_PATH %>')
  line.gsub!(/#{RUBY_STACK_TRACE_FILE_LINE}/ , '<%= RUBY_STACK_TRACE_FILE_LINE %>')
#  line.gsub!(/#{WHITESPACE_REGION}/          , '<%= WHITESPACE_REGION %>')
  line.gsub!(/(#{REGEX_SPECIAL_CHAR})/) { |m| '\\' + m }
  line = '\\A' + line + '\\s*\\Z'
  puts line
  STDERR.puts ERB.new(line).result
end
