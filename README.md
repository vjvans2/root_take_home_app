# Problem Statement README

#### How Do I Run It?
* Navigate to the folder with the `launcher.rb` in it, and go `ruby launcher.rb file_name.txt` assuming that "file_name.txt" is also in that same folder.

#### Description

The solution is launched from the `launcher.rb` file.  This file utilizes the `ARGV` in order to grab the `filepath` argument and utilize it within the `driving_history.rb`.  There are some length checks and error handling on the `ARGV` to ensure that we are only submitting one argument, but other than that, it's primary purpose is to get us to the `driving_history.rb`.  

The `DrivingHistory` model takes in the `filepath` provided by the `Launcher` and we dive right in to the logic through the `#self.report` as a class method.  Through the `#initialize` method we read the file, `chomp` it into an array of rows, and instantitate the `driver_trips_array` where we are going to store our driver and trip data as we process the file.

`#self.report` calls `#report`: our only public method in the class.  `#report` is a short method, only because it is delegating the logic to other private methods to comprise the pieces together.  I elected to have a `rescue` statement encompass this logic so it would grab the created error classes as they rose to the console.  While testing, the console did not show the bubbled up errors clearly, so I took advantage of the `StandardError => e` to make a clean and clear error for the console.

`#file_valid?` is checking to ensure that the file submitted is a valid '.txt' file and that the file is not empty.  I utilized a regex to allow any filename with `/`, `_`, letters, and numbers as long as it ended with `.txt`.

`#output_report` will ultimately return the report within the console.  It needs to manipulate the file data first through the `#driver_trips` method.

`#driver_trips` loops through the lines of the file and organizes matching Driver and Trip information into the `driver_trips_array` array.  The bulk of the logic lives within a case statement after checking the first cell of the `split`.  Names with spaces in them have been accounted for with the `shift` and `tap` methods called for the `name` variable within the 'Driver' and 'Trip' cases.

If the `driver_trips_array` array is empty or does not have an entry with a matching name, then it will create an object with the current row information and add it to the array.  When the 'Trip' case is hit, a `#trip_instance` is created/added to the `driver_trips_array` object of the person of the matching name.  A `#trip_instance` adds the 'start', 'end', and 'miles' information to an object to be added to the `trips` array within the `driver_trips_array` object.  In order to get the correct indexes if the names have spaces, the `name_index_differential` is utilized.

`#driver_trips` has error handling checking for incorrect delimiters, invalid commands within the file, and ensuring that all provided Trips have Drivers.  Drivers do not need Trips, but Trips need Drivers.  This is handled with the `name_verified` property.  Before some math and string manipulation happens, we need to format our array even more within `#formatted_driver_trips`.

`#formatted_driver_trips` does the math and adds the properties we are going to eventually use within our report if the trips are valid.  `#mph_calc` includes the logic to exclude trips that have an mph < 5 or > 100 and are branded as `:invalid` if so.  Since miles is a "float" in string form, we need to hit it with a `to_f` before rounding.  If we hit it with `to_i` it always rounds down.  `Time.parse(time_as_a_string)` successfully parses our provided times, even in military time.  It returns the values in seconds, so we divide by 60 to get to minutes, and by 60 again to get to hours.  

The miles calculation rejects the `:invalid` entries from above and does a `to_f` and `float` on the miles.  The final check is sifting out any `driver_trips` that do not have a verified name - Trips without Drivers.  We sort by miles with the most on top per the documentation.

Now that we have all of our information set up, we can set up our return string in the `#generate_output` method.  If a Driver exists, but has no Trips, they show as "0 miles", so we need to account for that before adding the `mph` piece for those with trips.  `.strip` removes the final `\n` after the looped string manipulation.  

As long as no errors were tripped, the string is returned to the `Launcher` and shown in the console.

#### Testing

The process was heavily driven by TDD through the `driving_history_spec.rb` file and fringe cases are addressed and validated within the file.
 * Drivers and Trips can be in any order, even non-sequential. (tests #1, 2, 3)
 * Files with valid Drivers will always show a record, even if there is not a trip.  If a Trip is provided without a Driver, but there are records that have valid Driver/Trip data, then only the valid data will be shown in the report.  (tests #6, 7)
 * No limit to amount of lines or trips.  Empty lines are ignored. (tests #4, 5)
 * Spaced names are allowed. (tests #10, 11)
 * MPH limits do not impede math or reporting (tests #8, 8A, 9, 9A)
 * Custom errors trigger when conditions are met (tests #12-17)
