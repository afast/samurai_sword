class Ushiwaka < Character
  # Cada vez que sufras una herida a causa de un arma, roba una carta del mazo.
  def draw_card_after_receiving_damage?(type)
    type == :weapon
  end

  def resistance
    4
  end
end
