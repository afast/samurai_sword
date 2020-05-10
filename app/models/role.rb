class Role
  def visible
    false
  end

  def initial_honor(amount_players)
    if amount_players > 5
      4
    else
      if amount_players == 3 and self.is_a?(Shogun)
        6
      else
        3
      end
    end
  end

  def to_s
    self.class.to_s
  end

  def as_json
    to_s.downcase
  end
end
