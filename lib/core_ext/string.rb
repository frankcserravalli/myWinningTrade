String.class_eval do
  def to_past
    if self.to_s == "Buy"
      return "Bought"
    end
    if self.to_s == "Sell"
      return "Sold"
    end
    if self.to_s == "ShortSellBorrow"
      return "Covered"
    end
  end
end
