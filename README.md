# Problem Statement README

(how do you utilize the code? - I need to know how to do it)

The logic of my solution is in two logic files an a spec file.  I will highlight the high level approaches and thought processes and some of the crunchier bits of the code.

The solution is launched from the `launcher.rb` file.  This file utilizes the `ARGV` concept in order to grab the `filepath` and utilize it within the `driving_history.rb`.  There are some length checks and error handling on the `ARGV` to ensure that we are only submitting one `filepath` argument, but other than that, it's primary purpose is to get us to the `driving_history.rb`.  

I made and worked with the `DrivingHistory` model before I made the `Launcher` because I wanted to ensure that the logic of the problem was addressed, tested, and sound before I focused on it was going to be accessed.  The `DrivingHistory` model takes in the `filepath` from the `Launcher` argument and we dive right in to the logic through the `self.report` as a class method.  Through the `initialize` method we read the file, `chomp` it into an array, and instantitate the `driver_trips_array` where we are going to store our driver and trip data as we process the file.

`self.report` calls `report`: our only public method in the class.  `report` is a short method, only because it is delegating the logic to other private methods to comprise the pieces together.  I elected to have a `rescue` statement encompass this logic so it would grab the created error classes as they rose to the console.  While testing, the console did not show the bubbled up errors clearly, so I took advantage of the `StandardError => e` to make a clean and clear error for the console.

`file_valid?` is checking to ensure that the file submitted is a valid '.txt' file and that the file is not empty.  Unit tests # 13, 15, and 16 validate the file type and presence checks.

`output_report` will ultimately return the report within the console.  It needs to manipulate the file data first through the `driver_trips` method.

#### CLEAN ME UP
`driver_trips` loops through the lines of the file and organizes matching Driver and Trip information into the `driver_trips_array` array.  The bulk of the logic lives within a case statement after checking the first cell of the `split`.  Names with spaces in them have been accounted for with the `shift` and `tap` methods called in the 'Driver' and 'Trip' case statements respectively.

If the `driver_trips_array` array is empty or does not have an entry with a matching name, then it will create an object with the row information and add it to the array.  The `name_verified` property exists because testing revealed that without something in place to double check, a 'Trip' entry would double-dip and add the name and trip information without needing a matching 'Driver' object in the file.  When the 'Trip' case is hit, a `trip_instance` is created/added to the `driver_trips_array` object of the person of the matching name.  A `trip_instance` adds the 'start', 'end', and 'miles' information to an object to be added to the `trips` array within the `driver_trips_array` object.  In order to get the correct indexes if the names have spaces, the `name_index_differential` is utilized.

`driver_trips` has error handling checking for incorrect delimiters, invalid commands, and ensuring that all provided Trips have Drivers.  Drivers do not need Trips, but Trips need Drivers.  Before some math happens, we need to format our array even more within `formatted_driver_trips`.

`formatted_driver_trips` does the math and adds the properties we are going to eventually use within our report if the trips are valid.  `mph_calc` includes the logic to exclude trips that have an mph < 5 or > 100 and are branded as `:invalid` if so.  Since miles is a "float" in string form, we need to hit it with a `to_f` before rounding.  If we hit it with `to_i` it always rounds down.  `Time.parse(time_as_a_string)` returns seconds, so we divide by 60 to get to minutes, and by 60 again to get to hours.  

The miles calculation rejects the `:invalid` from above and then the final check is sifting out any `driver_trips` that do no have a verified name - Trips without Drivers.  We sort by miles, per the documentation, reverse to put the highest on top, and then sort by name because not seeing them in alphabetical order was killing me.

Now that we have all of our information set up, we can set up our return string.  If a Driver exists, but has no Trips, then they show as with "0 miles", so we need to account for that before adding the `mph` piece of the string together.  `.strip` removes the final `\n` after the looped string manipulation.  

As long as no errors were tripped, the string is returned to the `Launcher` and shown in the console.

---

The process was heavily driven by TDD through the `driving_history_spec.rb` file and fringe cases are addressed and validated within the file.
 * Drivers and Trips can be in any order, even non-sequential. (tests #1, 2, 3)
 * Files with valid Drivers will always show a record, even if there is not a trip.  If a Trip is provided without a Driver, but there are records that have valid Driver/Trip data, then only the valid data will be shown in the report.  (tests #6, 7)
 * No limit to amount of lines or trips.  Empty lines are ignored. (tests #4, 5)
 * Spaced names are allowed. (tests #10, 11)
 * MPH limits do not impede math or reporting (tests #8, 8A, 9, 9A)
