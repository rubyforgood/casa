module GenerateToken
  extend ActiveSupport::Concern

  included do
    def ensure_token
      self.token = generate_hex(:token) unless token.present?
    end

    def generate_hex(column)
      loop do
        hex = SecureRandom.hex(32)
        break hex unless self.class.where(column => hex).any?
      end
    end
  end
end
