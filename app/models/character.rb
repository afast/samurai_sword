class Character
  attr_reader :resistance

  def base_distance
    1
  end

  def resistance
    1
  end

  def to_s
    self.class.to_s
  end
end
