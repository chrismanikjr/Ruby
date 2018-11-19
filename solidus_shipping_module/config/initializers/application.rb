config = Rails.application.config
config.spree.calculators.tax_rates << Spree::Calculator::Shipping::WeightCalculator
config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::WeightCalculator
config.spree.calculators.promotion_actions_create_adjustments << Spree::Calculator::Shipping::WeightCalculator
config.spree.calculators.tax_rates << Spree::Calculator::Shipping::CargoCalculator
config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::CargoCalculator
config.spree.calculators.promotion_actions_create_adjustments << Spree::Calculator::Shipping::CargoCalculator