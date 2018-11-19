module Spree
  module Calculator::Shipping
    class CargoCalculator < ShippingCalculator
      def self.description
        "By cargo"
      end

      def compute(order=nil)
        content_items = order.contents
        # total_weight = total_weight(content_items)
        shipping_price = shipping_price(order)
        # total_cost = (total_weight * shipping_price) + adm_fee(order)

        total_cost = (shipping_price) + adm_fee(order)
        return total_cost
      end

      def available?(object)
        price = shipping_price(object)
        if price > 0
          return true
        else
          return false
        end
      end

      private

      def shipping_price(order)
        shipping_rate = shipping_rate(order)
        if shipping_rate
          shipping_rate.price
        else
          0
        end
      end

      def adm_fee(order)
        # shipping_rate = shipping_rate(order)
        # if shipping_rate
        #   shipping_rate.adm_price
        # else
        #   0
        # end
        cargo_method = selected_cargo_method(order)
        if cargo_method
          if cargo_method.adm_price.nil? 
            0
          else
            cargo_method.adm_price
          end
        else
          0
        end
      end

      def total_weight(contents)
        weight = 0
        contents.each do |item|
          item_weight = item.variant.weight > 0.0 ? item.variant.weight : 1
          weight += item.line_item.quantity * item_weight
        end
        weight.ceil
      end

      def weight(order)
        shipping_rate = shipping_rate(order)
        if shipping_rate
          shipping_rate.weight
        else
          1
        end
      end

      def shipping_rate(order)
        weight = total_weight(order.contents)
        city = City.find_by_name(order.shipment.order.ship_address.city)
        cargo_method = self.calculable.cargo_shipping_rates_per_methods.find_by_city_id(city.id)
        return false if cargo_method.nil?

        min_weight = cargo_method.cargo_detail_shipping_rates_per_methods.order(weight: :asc).first.weight
        if weight < min_weight
          weight = min_weight
        end

        found = cargo_method.cargo_detail_shipping_rates_per_methods.find_by_weight(weight)
        return found
      end

      def selected_cargo_method(order)
        city = City.find_by_name(order.shipment.order.ship_address.city)
        cargo_method = self.calculable.cargo_shipping_rates_per_methods.find_by_city_id(city.id)
        return cargo_method
      end
    end
  end
end