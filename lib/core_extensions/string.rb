class String
  def to_boolean
    return false unless downcase == "true"

    ActiveModel::Type::Boolean.new.cast(self)
  end
end
