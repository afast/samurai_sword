class Tomoe < Character
  # Cada vez que tu arma inflija una herida a un jugador, roba una carta del mazo
  def draw_card_after_making_damage?(type)
    type == :weapon
  end

  def resistance
    5
  end
end
