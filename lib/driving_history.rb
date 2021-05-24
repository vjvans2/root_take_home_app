class DrivingHistory
  attr_accessor :filepath, :file_data, :driver_trips_array

  FILE_REGEX = '^[A-Za-z0-9\/\_\ ]+\.txt$' # any combo of directories, text, underscores, spaces as long as it has a '.txt' at the end'
  InvalidFileError = Class.new(StandardError)
  InvalidCommandError = Class.new(StandardError)
  DelimiterError = Class.new(StandardError)
  NoDriversError = Class.new(StandardError)

  def initialize(filepath)
    @filepath = filepath
    @file_data = File.open(filepath).readlines.map(&:chomp)
    @driver_trips_array = []
  end

  def self.report(filepath)
    new(filepath).report
  end

  def report
    begin
      file_valid?
      output_report
    rescue Exception => e
      "ERROR - #{e.class}: #{e.message}"
    end
  end

  private

  def trip_instance(split, single_word_name = true)
    {
      start: split[single_word_name ? 2 : 3], 
      end: split[single_word_name ? 3 : 4],
      miles: split[single_word_name ? 4 : 5],
    }
  end

  def generate_output(driver_trips)
    output = ''
    driver_trips.each do |dt|
      dt[:mph] = mph_calc(dt[:trips])
      dt[:miles] = total_miles_calc(dt[:trips])
    end

    driver_trips.sort_by { |dt| dt[:miles] }.reverse.sort_by { |dt| dt[:name] }.each do |x|
      output += "#{x[:name]}: #{x[:miles]} miles"

      if x[:miles] == 0
        output += "\n"
        next
      end

      output += " @ #{x[:mph]} mph\n"
    end

    output.strip # the strip removes the final \n
  end

  def total_miles_calc(trips)
    return 0 if trips.empty?

    miles = 0
    trips.select { |tr| !tr[:invalid]}
         .each { |t| miles += t[:miles].to_f.round } # going "to_i" always rounds down, round with no params handles the int-ness
    miles
  end

  def mph_calc(trips)
    return 0 if trips.empty?

    require 'time'
    mphs = []
    trips.each do |t|
      start = Time.parse(t[:start])
      finish = Time.parse(t[:end])
      miles = t[:miles].to_f.round
      hour_diff = (finish-start)/3600 # in seconds, /60 to get to minutes, /60 to get to hours
      trip_mph = miles/hour_diff

      if trip_mph < 5 || trip_mph > 100
        t[:invalid] = true
        next
      end

      mphs << trip_mph
    end

    (mphs.sum / mphs.length).round || 0
  end

  def file_valid?
    raise InvalidFileError, 'The provided file is not a .txt type.' if filepath.match(FILE_REGEX).nil?
    raise InvalidFileError, 'The provided file has no contents.' if file_data.empty?
  end

  def output_report
    dt = get_driver_trips
    generate_output(dt)
  end

  def get_driver_trips
    file_data.each do |row|
      next if row.empty?
      
      split = row.split(' ')
      raise DelimiterError, 'This file does not appear to be utilizing a space as a delimiter.' if split.length == 1

      name = split[1] # MARY SUE 
      dt_by_name = driver_trips_array.select { |dta| dta[:name] == name }.first

      if split[0] == 'Driver'
        if driver_trips_array.empty? || driver_trips_array.select { |dt| dt[:name] == name }.empty?
            driver_trips_array <<  {name: name, trips: [], name_verified: true }
        elsif !dt_by_name.empty? && dt_by_name[:name_verified] == false
          dt_by_name[:name_verified] = true
        end
      elsif split[0] == 'Trip'
        if driver_trips_array.empty? || dt_by_name.nil?
          driver_trips_array <<  {name: name, trips: [trip_instance(split)], name_verified: false }
        else
          dt_by_name[:trips] << trip_instance(split)
        end
      else
        raise InvalidCommandError, "The provided \"#{split[0]}\" command is invalid for this app."
      end

    end

    raise NoDriversError, 'Drivers do not exist for all provided Trips' if driver_trips_array.all? { |d| d[:name_verified] == false }

    driver_trips_array.select { |d| d[:name_verified] == true}
  end
end
