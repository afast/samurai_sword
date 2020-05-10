class Ginchiyo < Character
  # Sufre una herida menos por armass (minimo 1)
  def resistance
    4
  end

  def final_damage(amount, type)
    if amount > 1 && type == :weapon
      amount - 1
    else
      amount
    end
  end
end
