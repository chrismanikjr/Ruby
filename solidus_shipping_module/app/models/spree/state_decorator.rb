Spree::State.class_eval do
  has_many :cities, dependent: :destroy
end