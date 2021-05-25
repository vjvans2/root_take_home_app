class DrivingHistory
  require 'time'

  FILE_REGEX = '^[A-Za-z0-9\/\_\ ]+\.txt$'.freeze # any combo of directories, text, underscores, spaces as long as it has a '.txt' at the end'
  InvalidFileError = Class.new(StandardError)
  InvalidCommandError = Class.new(StandardError)
  DelimiterError = Class.new(StandardError)
  NoDriversError = Class.new(StandardError)
  DriverTripsError = Class.new(StandardError)

  def initialize(filepath)
    @filepath = filepath
    @file_data = File.open(filepath).readlines.map(&:chomp)
    @driver_trips_array = []
  end

  def self.report(filepath)
    new(filepath).report
  end

  def report
    file_valid?
    output_report
  rescue StandardError => e
    "ERROR - #{e.class}: #{e.message}"
  end

  private

  attr_accessor :filepath, :file_data, :driver_trips_array

  def file_valid?
    raise InvalidFileError, 'The provided file is not a .txt type.' if filepath.match(FILE_REGEX).nil?
    raise InvalidFileError, 'The provided file has no contents.' if file_data.empty?
  end

  def output_report
    dt = driver_trips
    raise DriverTripsError if dt.empty? #shouldn't, but just in case

    generate_output(dt)
  end

  def driver_trips
    file_data.each do |row|
      next if row.empty?

      split = row.split(' ')
      copy_split = split.dup

      raise DelimiterError, 'This file does not appear to be utilizing a space as a delimiter.' if split.length == 1

      case split[0]
      when 'Driver'
        name = copy_split.tap(&:shift).join(' ')
        dt_by_name = driver_trip_by_name(name)

        if driver_trips_array.empty? || driver_trips_array.select { |dt| dt[:name] == name }.empty?
          driver_trips_array <<  {name: name, trips: [], name_verified: true }
        elsif !dt_by_name.empty? && dt_by_name[:name_verified] == false
          dt_by_name[:name_verified] = true
        end
      when 'Trip'
        name_arr = copy_split.tap { |s| s.pop; s.pop; s.pop; s.shift; } #miles, end, start, command
        name_index_differential = name_arr.length - 1
        name = name_arr.join(' ')
        dt_by_name = driver_trip_by_name(name)

        if driver_trips_array.empty? || dt_by_name.nil?
          driver_trips_array << {name: name, trips: [trip_instance(split, name_index_differential)], name_verified: false }
        else
          dt_by_name[:trips] << trip_instance(split, name_index_differential)
        end
      else
        raise InvalidCommandError, "The provided \"#{split[0]}\" command is invalid for this app."
      end
    end

    raise NoDriversError, 'Drivers do not exist for all provided Trips' if
      driver_trips_array.all? { |d| d[:name_verified] == false }

    formatted_driver_trips(driver_trips_array)
  end

  def driver_trip_by_name(name)
    driver_trips_array.select { |dta| dta[:name] == name }.first
  end

  def trip_instance(split, name_index_differential)
    {
      start: split[2 + name_index_differential], 
      end: split[3 + name_index_differential],
      miles: split[4 + name_index_differential],
    }
  end

  def generate_output(driver_trips)
    output = ''
    driver_trips.each do |x|
      output += "#{x[:name]}: #{x[:miles]} miles"

      if x[:miles].zero?
        output += "\n"
        next
      end

      output += " @ #{x[:mph]} mph\n"
    end

    output.strip # the strip removes the final \n
  end

  def formatted_driver_trips(driver_trips)
    return [] if driver_trips.empty?

    driver_trips.each do |dt|
      dt[:mph] = mph_calc(dt[:trips])
      dt[:miles] = total_miles_calc(dt[:trips])
    end

    driver_trips
      .select { |d| d[:name_verified] == true }
      .sort_by { |dt| dt[:miles] }
      .reverse
      .sort_by { |dt| dt[:name] }
  end

  def total_miles_calc(trips)
    return 0 if trips.empty?

    miles = 0
    # going "to_i" always rounds down, round with no params handles the int-ness
    trips.reject { |tr| tr[:invalid] }.each { |t| miles += t[:miles].to_f.round }
    miles
  end

  def mph_calc(trips)
    return 0 if trips.empty?

    mphs = []
    trips.each do |t|
      start = Time.parse(t[:start])
      finish = Time.parse(t[:end])
      miles = t[:miles].to_f.round
      hour_diff = (finish - start) / 3600 # in seconds, /60 to get to minutes, /60 to get to hours
      trip_mph = miles / hour_diff

      if trip_mph < 5 || trip_mph > 100
        t[:invalid] = true
        next
      end

      mphs << trip_mph
    end

    (mphs.sum / mphs.length).round || 0
  end
end
