require Rails.root.join("app/strategies/phone_number_strategy")

Warden::Strategies.add(:phone_number, PhoneNumberStrategy)