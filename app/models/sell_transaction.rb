class SellTransaction
  include ActiveModel::Validations
  def persisted; false end
end
