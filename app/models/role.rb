class Role
  def visible
    false
  end

  def initial_honor(amount_players)
    if amount_players > 5
      4
    else
      3
    end
  end

  def to_s
    self.class.to_s
  end
end
