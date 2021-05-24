require './driving_history'

class Launcher
  if ARGV.empty?
    p 'A file name argument was not provided.  Please provide a file name.'
    exit
  elsif ARGV.length > 1
    p 'Too many arguments were provided.  Please only provide one file name.'
    exit
  end
  
  filename = ARGV.first
  p DrivingHistory.report(filename)
end
