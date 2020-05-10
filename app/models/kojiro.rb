class Kojiro < Character
  # Tus armas pueden atacar con cualquier dificultad
  def reach_modifier
    99
  end

  def resistance
    5
  end
end
