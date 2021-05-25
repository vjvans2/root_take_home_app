# frozen_string_literal: true

# run me with 'bundle exec rspec ./spec/driving_history_spec.rb:76'

require 'driving_history'

RSpec.describe DrivingHistory do
  subject { described_class.report(filename) }

  let(:filename) { 'spec/test/test_data.txt' }
  let(:file) { File.write(filename, file_contents) }

  before :each do
    file
  end

  describe '#report' do
    # HAPPY PATHS
    context 'when a valid file is provided - 1:2, 1:1, 1:0 - provided order' do
      let(:file_contents) { "Driver A\nDriver B\nDriver C\nTrip A 07:15 07:45 15.9345\nTrip A 09:15 09:56 29.3\nTrip B 14:11 15:42 39.5" }
      let(:expected_report) { "A: 45 miles @ 37 mph\nB: 40 miles @ 26 mph\nC: 0 miles" }
      it 'returns the intended result' do
        expect(subject).to eq expected_report
      end
    end

    context 'when a valid file is provided - 1:2, 1:1, 1:0 - out of order' do
      let(:file_contents) { "Driver A\nTrip A 07:15 07:45 15.9345\nDriver B\nTrip A 09:15 09:56 29.3\nTrip B 14:11 15:42 39.5\nDriver C" }
      let(:expected_report) { "A: 45 miles @ 37 mph\nB: 40 miles @ 26 mph\nC: 0 miles" }
      it 'returns the intended result' do
        expect(subject).to eq expected_report
      end
    end

    context 'when a valid file is provided - A trip happens before a Driver is declared' do
      let(:file_contents) { "Driver A\nTrip C 07:15 07:45 15.9345\nDriver B\nTrip A 09:15 09:56 29.3\nTrip B 14:11 15:42 39.5\nDriver C" }
      let(:expected_report) { "A: 29 miles @ 42 mph\nB: 40 miles @ 26 mph\nC: 16 miles @ 32 mph" }
      it 'returns the intended result' do
        expect(subject).to eq expected_report
      end
    end

    context 'when a valid file is provided - 1:5, 1:0, 1:0 - out of order' do
      let(:file_contents) { "Driver A\nTrip A 07:15 07:45 15.9345\nDriver B\nTrip A 09:15 09:56 29.3\nTrip A 14:11 15:42 39.5\nDriver C\nTrip A 11:15 14:56 89.3\nTrip A 19:15 21:56 59.3" }
      let(:expected_report) { "A: 233 miles @ 29 mph\nB: 0 miles\nC: 0 miles" }
      it 'returns the intended result' do
        expect(subject).to eq expected_report
      end
    end
    
    context 'when a valid file is provided - with empty lines' do
      let(:file_contents) { "Driver A\n\n\nTrip A 07:15 07:45 15.9345\nDriver B\nTrip A 09:15 09:56 29.3\nTrip A 14:11 15:42 39.5\nDriver C\nTrip A 11:15 14:56 89.3\nTrip A 19:15 21:56 59.3" }
      let(:expected_report) { "A: 233 miles @ 29 mph\nB: 0 miles\nC: 0 miles" }
      it 'returns the intended result' do
        expect(subject).to eq expected_report
      end
    end

    context 'when a file with all drivers and no trips is submitted' do
      let(:file_contents) { "Driver A\nDriver B\nDriver C" }
      let(:expected_report) { "A: 0 miles\nB: 0 miles\nC: 0 miles" }
      it 'returns the intended result' do
        expect(subject).to eq expected_report
      end
    end

    context 'when a driver is defined, but it isn\'t the driver of the provided trip' do
      let(:file_contents) { "Driver A\nTrip B 07:15 07:45 15.9345" }
      let(:expected_report) { 'A: 0 miles' }
      it 'should return a response for Driver A of zero, but no response for B' do
        expect(subject).to eq expected_report
      end
    end

    context 'when the driver is defined, but has an invalid fast trip' do
      let(:file_contents) { "Driver A\nTrip A 07:15 07:45 30\nTrip A 16:00 16:01 200" }
      let(:expected_report) { 'A: 30 miles @ 60 mph'}
      it 'should return a response for the valid trips of A' do
        expect(subject).to eq expected_report
      end
    end

    context 'when the driver is defined, but has an invalid slow trip' do
      let(:file_contents) { "Driver A\nTrip A 07:15 07:45 30\nTrip A 16:00 16:01 2" }
      let(:expected_report) { 'A: 30 miles @ 60 mph'}
      it 'should return a response for the valid trips of A' do
        expect(subject).to eq expected_report
      end
    end

    context 'when the driver is defined with a valid trip, but their name has a space' do
      let(:file_contents) { "Driver Mary Sue\nTrip Mary Sue 07:15 07:45 30" }
      let(:expected_report) { 'Mary Sue: 30 miles @ 60 mph' }
      it 'should return a response for the valid trips of A' do
        expect(subject).to eq expected_report
      end
    end

    context 'when there are single and spaced names within the same file' do
      let(:file_contents) { "Driver Mary Sue\nTrip Mary Sue 07:15 07:45 15.9345\nDriver Jolly Green Giant\nTrip Mary Sue 09:15 09:56 29.3\nTrip His Majesty Queen Elizabeth II 14:11 15:42 39.5\nDriver His Majesty Queen Elizabeth II\nTrip Mary Sue 11:15 14:56 89.3\nTrip Mary Sue 19:15 21:56 59.3" }
      let(:expected_report) { "His Majesty Queen Elizabeth II: 40 miles @ 26 mph\nJolly Green Giant: 0 miles\nMary Sue: 193 miles @ 30 mph" }
      it 'should return a response as expected' do
        expect(subject).to eq expected_report
      end
    end

    # NOT_HAPPY PATHS

    context 'when an file is provided without a driver being declared for all trips' do
      let(:file_contents) { "Trip A 07:15 07:45 15.9345\nTrip B 14:11 15:42 39.5" }
      it 'should return a NoDriversError' do
        expect(subject).to eq 'ERROR - DrivingHistory::NoDriversError: Drivers do not exist for all provided Trips'
      end
    end

    context 'when the file provided is an empty string' do
      let(:file_contents) { '' }
      it 'should return an InvalidFileError' do
        expect(subject).to eq 'ERROR - DrivingHistory::InvalidFileError: The provided file has no contents.'
      end
    end

    context 'when the file provided is delimited incorrectly' do
      let(:file_contents) { "Driver|A|\nTrip|A|07:15|07:45|15.9345" }
      it 'should return a DelimiterError' do
        expect(subject).to eq 'ERROR - DrivingHistory::DelimiterError: This file does not appear to be utilizing a space as a delimiter.'
      end
    end

    context 'when the file provided is the incorrect type' do
      let(:file_contents) { "Driver A\nDriver B\nDriver C\nTrip A 07:15 07:45 15.9345\nTrip A 09:15 09:56 29.3\nTrip B 14:11 15:42 39.5" }
      let(:filename) { 'spec/test/test_data.css' }
      it 'should return an InvalidFileError' do
        expect(subject).to eq 'ERROR - DrivingHistory::InvalidFileError: The provided file is not a .txt type.'
      end
    end

    context 'when the file type provided is way out in left field' do
      let(:file_contents) { "Driver A\nDriver B\nDriver C\nTrip A 07:15 07:45 15.9345\nTrip A 09:15 09:56 29.3\nTrip B 14:11 15:42 39.5" }
      let(:filename) { 'spec/test/test_data.ppt' }
      it 'should return an InvalidFileError' do
        expect(subject).to eq 'ERROR - DrivingHistory::InvalidFileError: The provided file is not a .txt type.'
      end
    end

    context 'when the file includes a command that is invalid' do
      let(:file_contents) { "Driver A\nTrip A 07:15 07:45 15.9345\nHi Mom" }
      it 'should return an InvalidFileError' do
        expect(subject).to eq 'ERROR - DrivingHistory::InvalidCommandError: The provided "Hi" command is invalid for this app.'
      end
    end
  end
end
