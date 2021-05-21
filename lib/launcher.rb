require './driving_history'

filename = ARGV[0]
p DrivingHistory.report(filename)
