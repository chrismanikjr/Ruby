module Spree
  module Calculator::Shipping
    class WeightCalculator < ShippingCalculator
      def self.description
        "By weight & city"
      end

      def compute(package=nil)
        content_items = package.contents
        total_weight = total_weight(content_items, min_weight(package))
        shipping_price = shipping_price(package)

        return false if shipping_price.nil?

        total_cost = (total_weight * shipping_price) + adm_fee(package)

        puts "=============>>>>> #{self.calculable.name}: #{total_cost} - #{adm_fee(package)} - #{total_weight}"
        return total_cost
      end

      def available?(object)
        price = shipping_price(object)
        if !price.nil?
          return true
        else
          return false
        end
      end

      private

      def shipping_price(object)
        shipping_rate = shipping_rate(object)
        if shipping_rate
          shipping_rate.price
        else
          nil
        end
      end

      def adm_fee(object)
        shipping_rate = shipping_rate(object)
        if shipping_rate
          shipping_rate.adm_price
        else
          0
        end
      end

      def total_weight(contents, min_weight)
        weight = 0
        contents.each do |item|
          item_weight = item.variant.weight
          weight += item.line_item.quantity * item_weight
        end
        weight = weight > min_weight ? weight : min_weight
        weight.ceil
      end

      def min_weight(object)
        shipping_rate = shipping_rate(object)
        if shipping_rate
          shipping_rate.min_weight
        else
          1
        end
      end

      def shipping_rate(object)
        city = Spree::City.find_by_name(object.shipment.order.ship_address.city)
        found = self.calculable.shipping_rates_per_methods.find_by_city_id(city.id)
        return found
      end
    end
  end
end