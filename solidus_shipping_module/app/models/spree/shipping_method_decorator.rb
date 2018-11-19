Spree::ShippingMethod.class_eval do
  has_many :shipping_rates_per_methods, dependent: :destroy
  has_many :cargo_shipping_rates_per_methods, dependent: :destroy
end