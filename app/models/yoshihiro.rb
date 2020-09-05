class Yoshihiro < Character
  def resistance
    8
  end

  def final_damage(amount, type)
    if type == :weapon
      amount + 1
    else
      amount
    end
  end
end
