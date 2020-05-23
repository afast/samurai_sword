class Chiyome < Character
  # Solo puede ser herida por armas
  def resistance
    4
  end

  def can_be_hurt_by?(card)
    card.type == :weapon
  end
end
