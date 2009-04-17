module CustomMatchers
  def take_more_than(seconds)
    simple_matcher("to take more than #{seconds} seconds") { |given| given > seconds }
  end
end