class Musashi < Character
  # Tus armas infligen una herida adicional
  def resistance
    5
  end

  def damage_modifier(type)
    type == :weapon ? 1 : 0
  end
end
