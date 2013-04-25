module AccountBonusHelper

  def convert_option_to_amount(bonus_option)
    case bonus_option
      when "option-1-bonus"
        99
      when "option-2-bonus"
        199
      when "option-3-bonus"
        299
      when "option-4-bonus"
        399
      when "option-5-bonus"
        499
      when "option-6-bonus"
        799
      else
        0
    end
  end
end
