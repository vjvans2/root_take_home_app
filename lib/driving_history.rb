class DrivingHistory
  FILE_REGEX = '^[A-Za-z0-9\/\_\ ]+\.txt$'

  attr_accessor :filepath, :file_data

  InvalidFileError = Class.new(StandardError)
  InvalidCommandError = Class.new(StandardError)

  def initialize(filepath)
    @filepath = filepath
  end

  def self.report(filepath)
    new(filepath).report
  end

  def report
    'hi dood'
    # catch and rescue errors for performance
    # file_valid?
    
    # output_report    

  end

  private

  def file_data
    @file_data = File.open(filepath)&.readlines.map(&:chomp)
  end

  def file_valid?
    # is the filepath a type .txt?  - this may be best got with a regex to check the last four char
    raise InvalidFileError, 'file is not a .txt' if filepath.match(FILE_REGEX).nil?
    match = filepath.match(FILE_REGEX).nil?

    # is the file populated?
    raise InvalidFileError, 'file is not populated' if file_data.empty?

    # is it delimited correctly?  Should we try to perceive it? 2.0?
  end

  def output_report
    generate_output(driver_trips)
  end

  def driver_trips
    dts = [] # make me class level? I need the methods to be able to add something to the array
    # or I can make it more like driver_trips << driver(row)

    file_data.each do |row|
      split = row.split(' ')
      if split[0] == 'Driver'
        #driver things
      elsif split[0] == 'Trip'
        #trip things
      else
        raise InvalidCommandError, "The provided #{split[0]} is invalid for this app."
    end
  end
  
  # # DO NOT FORGET TO ACCOUNT FOR MARY SUE (names with spaces)

  def driver(row)
    # check to see if the name (split[1]) exists in the array of objects
    # if it does, next
    # if it doesnt - make an object: {driver: 'name', trips: []}
  end

  def trip(row)
    # check to see if the name (split[1]) exists in the array of objects
    # if it does, add it to the trip array
    # if it doesnt - make an object: {driver: 'name', trips: [current_trip]}
  end

  def generate_output(driver_trips)
    output = ''
    driver_trips.each do |dt|
      trip_data = calc_trip_data(dt[:trips])
      driver_data_string = "#{dt[:name]}: #{trip_data}\n"

      output += driver_data_string
    end
  end

  def calc_trip_data(trips)
    return '0 miles' if trips.empty?
    
    miles = miles_calc(trips)
    mph = mph_calc(trips)

    "#{miles} miles @ #{mph} mph"
  end

  def miles_calc(trips)
  end

  def mph_calc(trips)
  end
end
end
