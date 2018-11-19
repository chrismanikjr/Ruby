class CreateTableSpreeCargoShippingRatesPerMethods < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_cargo_shipping_rates_per_methods do |t|
      t.integer :country_id
      t.integer :state_id
      t.integer :city_id
      t.string :country_name
      t.string :state_name
      t.string :city_name
      t.string :etd
      t.integer :shipping_method_id
      t.decimal :adm_price,     precision: 8, scale: 2
      t.timestamps
    end
  end
end
