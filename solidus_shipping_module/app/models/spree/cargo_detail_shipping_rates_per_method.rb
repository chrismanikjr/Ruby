class Spree::CargoDetailShippingRatesPerMethod < Spree::Base
  belongs_to :cargo_shipping_rates_per_method

  validates :price, :weight, presence: true
end
