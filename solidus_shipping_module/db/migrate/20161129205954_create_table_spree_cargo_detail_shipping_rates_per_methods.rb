class CreateTableSpreeCargoDetailShippingRatesPerMethods < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_cargo_detail_shipping_rates_per_methods do |t|
      t.integer :cargo_shipping_rates_per_method_id
      t.decimal :price,     precision: 8, scale: 2
      t.integer :weight, default: 1
    end
  end
end
