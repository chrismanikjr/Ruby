class Spree::ShippingRatesPerMethod < Spree::Base
  include Filterable
  belongs_to :shipping_method

  validates :country_id, :city_id, :state_id, :price, :shipping_method_id, :etd, presence: true
  validates :city_id, :uniqueness => {:scope => [:shipping_method_id, :state_id]}

  after_create :set_fields_name

  scope :province_contain, -> (province){where("state_name like ?", "%#{province}%")}
  scope :city_contain, -> (city){where("city_name like ?", "%#{city}%")}

  def self.import(file, shipping_method_id)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      product = where(shipping_method_id: shipping_method_id, city_name: row["city_name"], state_name: row["state_name"],
        country_name: row["country_name"]).first || new
      product.attributes = row.to_hash.slice(*row.to_hash.keys)
      product.shipping_method_id = shipping_method_id
      product.set_fields_id(product)
      product.save
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

  def set_fields_id(product)
    product.city_id = Spree::City.find_by_name(product.city_name).id
    product.state_id = Spree::State.find_by_name(product.state_name).id 
    product.country_id = Spree::Country.find_by_name(product.country_name).id
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
