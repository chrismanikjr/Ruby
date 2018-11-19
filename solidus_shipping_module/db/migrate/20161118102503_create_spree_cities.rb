class CreateSpreeCities < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_cities do |t|
      t.integer :country_id
      t.integer :state_id
      t.string :name
      t.timestamps
    end
  end
end
