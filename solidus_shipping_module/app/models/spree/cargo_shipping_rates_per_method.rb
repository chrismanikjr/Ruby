class Spree::CargoShippingRatesPerMethod < Spree::Base
  include Filterable
  belongs_to :shipping_method
  has_many :cargo_detail_shipping_rates_per_methods

  validates :country_id, :city_id, :state_id, :shipping_method_id, :etd, presence: true
  validates :city_id, :uniqueness => {:scope => [:country_id, :state_id]}

  after_create :set_fields_name

  scope :province_contain, -> (province){where("state_name like ?", "%#{province}%")}
  scope :city_contain, -> (city){where("city_name like ?", "%#{city}%")}

  def self.import(file, shipping_method_id)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      cargo = where(shipping_method_id: shipping_method_id, city_name: row["city_name"], state_name: row["state_name"],
        country_name: row["country_name"]).first || new
      # cargo.attributes = row.to_hash.slice(*row.to_hash.keys)
      # byebug
      cargo.city_name = row["city_name"]
      cargo.state_name = row["state_name"]
      cargo.country_name = row["country_name"]
      cargo.adm_price = row["adm_price"]
      cargo.etd = row["etd"]
      cargo.shipping_method_id = shipping_method_id
      cargo.save(validate: false)
      list_detail = []
      for weight in 1..50 do
        next if row["price_"+weight.to_s].nil?
        
        price = row["price_"+weight.to_s].to_f
        detail = cargo.cargo_detail_shipping_rates_per_methods.find_by_weight(weight)
        if detail
          puts "A "+price.to_s
          detail.price = price
          detail.save(validate: false)
        else
          puts "B"+price.to_s
          detail = Spree::CargoDetailShippingRatesPerMethod.new
          detail.price = price
          detail.cargo_shipping_rates_per_method = cargo
          detail.weight = weight
        end
        list_detail << detail
        # detail.save(validate: false)
      end
      cargo.cargo_detail_shipping_rates_per_methods = list_detail
      cargo.set_fields_id(cargo)
      cargo.save(validate: false)
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path, nil, :ignore)
      when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path, packed: nil, file_warning: :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def set_fields_id(cargo)
    cargo.city_id = Spree::City.find_by_name(cargo.city_name).id
    cargo.state_id = Spree::State.find_by_name(cargo.state_name).id 
    cargo.country_id = Spree::Country.find_by_name(cargo.country_name).id
  end

  def set_fields_name
    if state_name.blank? || city_name.blank? || country_name.blank?
      self.state_name = Spree::State.find_by_id(state_id).name
      self.country_name = Spree::Country.find_by_id(country_id).name
      self.city_name = Spree::City.find_by_id(city_id).name
      self.save
    end
  end
end
