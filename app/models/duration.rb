class Duration

  def self.duration_str(seconds)
    seconds = seconds.to_i
    return "00:00" if seconds < 0
    m = ((seconds / 60) % 60).to_s.rjust(2, "0")
    s = (seconds % 60).to_s.rjust(2, "0")
    "#{m}:#{s}"
  end

  def self.minutes_str(seconds, format = "mins")
    seconds = seconds.to_i
    return "0 #{format}" if seconds.to_i < 0
    m = (seconds / 60) % 60
    return "1 #{format.chomp('s')}" if m == 1
    "#{m} #{format}"
  end

  def self.duration_str_to_int(str)
    digits_array = str.split(":").map(&:to_i)
    total = digits_array.first * 60
    total + digits_array.second
  end
end
