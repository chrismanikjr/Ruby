class ChangeDecimalToIntegerCargoPrice < ActiveRecord::Migration[5.0]
  def change
  	change_column :spree_cargo_detail_shipping_rates_per_methods, :price, :integer
  end
end
