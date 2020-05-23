class Character
  attr_reader :resistance

  def distance_modifier
    0
  end

  def can_be_hurt_by?(defend_from)
    [:weapon, :action].include?(defend_from.type)
  end

  def final_damage(amount, type)
    amount
  end

  def damage_modifier(type)
    0
  end

  def draw_card_after_making_damage?(type)
    false
  end

  def draw_card_after_receiving_damage?(type)
    false
  end

  def play_weapon_amount
    1
  end

  def draw_card_amount
    2
  end

  def reach_modifier
    0
  end

  def resistance
    1
  end

  def to_s
    self.class.to_s
  end

  def as_json
    to_s.downcase
  end
end
