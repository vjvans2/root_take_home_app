class DrivingHistory
  def initialize(file)
    @file = file
  end

  def self.report(file)
    new(file).report
  end

  def report
    private_string_method
  end

  private

  def private_string_method
    p 'hi dood'
  end
end
