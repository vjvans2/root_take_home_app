# frozen_string_literal: true

# run me with 'bundle exec rspec'

require 'driving_history'

RSpec.describe DrivingHistory do
  subject { described_class.report(filename) }

  let(:filename) { 'test_data.txt' }
  let(:file_contents) { "Driver A\nDriver B\nDriver C\nTrip A 07:15 07:45 15.9345\nTrip A 09:15 09:56 29.3\nTrip B 14:11 15:42 39.5" }
  let(:file) { File.write(filename, file_contents) }

  before do
    file
  end

  describe '#report' do
    # HAPPY PATHS
    context 'when a valid file is provided - 1:2, 1:1, 1:0 - provided order' do
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

    context 'when a valid file is provided - 1:5, 1:0, 1:0 - out of order' do
      let(:file_contents) { "Driver A\nTrip A 07:15 07:45 15.9345\nDriver B\nTrip A 09:15 09:56 29.3\nTrip A 14:11 15:42 39.5\nDriver C\nTrip A 11:15 14:56 89.3\nTrip A 19:15 21:56 59.3" }
      let(:expected_report) { "A: 233 miles @ 29 mph\nC: 0 miles\nB: 0 miles" }
      it 'returns the intended result' do
        expect(subject).to eq expected_report
      end
    end

    # add a test for empty rows lines within the file

  end
end
