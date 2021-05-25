require './driving_history'

class Launcher
  if ARGV.empty?
    p 'A file path argument was not provided.  Please provide a file path.'
    exit
  elsif ARGV.length > 1
    p 'Too many arguments were provided.  Please only provide one file path.'
    exit
  end

  filepath = ARGV.first
  p DrivingHistory.report(filepath)
end
