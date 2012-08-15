module ApplicationHelper
  def envolve_name_for(user,portfolio={})
    cash = user.account_balance
    portfolio_value = portfolio[:current_value]
    account_value = cash + portfolio_value

    "#{user.display_name} (#{number_to_abbreviated_currency(account_value)})"
  end

  def number_to_abbreviated_currency(n)
    suffixes = {
        (1..3) => '',
        (4..6) => 'k',
        (7..9) => 'M',
       (10..12) => 'B',
      (13..15) => 'T'
    }

    digit_count = n.floor.to_s.length
    matched_range = suffixes.keys.find { |r| r.include?(digit_count) }
    divisor = 10 ** (matched_range.first - 1)

    divided_value = (n / divisor.to_f)   
    divided_value_digit_count = divided_value.floor.to_s.length
    rounding_digits = [3-divided_value_digit_count,0].max
    rounded_value = divided_value.round(rounding_digits)

    suffix = suffixes[matched_range]
    "$#{rounded_value}#{suffix}"
  end
end
