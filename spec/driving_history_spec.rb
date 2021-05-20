# frozen_string_literal: true

# run me with 'bundle exec rspec'

require "driving_history"

RSpec.describe DrivingHistory do
  subject { described_class.report(file)}

  let(:file) { File.write('test_data.txt', file_contents) }
  let(:file_contents) { "Driver A\nDriver B\nDriver C\nTrip A 07:15 07:45 15.9345\nTrip A 09:15 09:56 29.3\nTrip B 14:11 15:42 39.5" }

  describe '#report' do
    context 'when the file is provided' do
      it 'returns "hi dood" because that\'s all I\'ve included' do
        expect(subject).to eq 'hi dood'
      end
    end
  end
end