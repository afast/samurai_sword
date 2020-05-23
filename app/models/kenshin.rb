class Kenshin < Character
  def resistance
    4
  end

  def can_be_hurt_by?(card)
    card.origami?
  end
end
