module Spree
  module Admin
    class CargoShippingRatesPerMethodsController < ResourceController
      def index
        @shipping_method = ShippingMethod.find_by_id params[:shipping_method_id]
        @rates = @shipping_method.cargo_shipping_rates_per_methods.filter(params.slice(:city_contain, :province_contain)).page(params[:page]).per(params[:per_page])
      end

      def import
        @shipping_method = ShippingMethod.find_by_id params[:shipping_method_id]
        if CargoShippingRatesPerMethod.import(params[:file], params[:shipping_method_id])
          redirect_to admin_cargo_shipping_rates_per_methods_path(shipping_method_id: @shipping_method.id), notice: "Products imported."
        end
      end

      def create
        @cargo_shipping_rates_per_method = Spree::CargoShippingRatesPerMethod.new(cargo_shipping_rates_per_method_params)
        if @cargo_shipping_rates_per_method.save
          if params[:cargo_shipping_rates_per_method]["price_1"].nil?
            #do nothing
          else
            for weight in 1..50 do
              price = params[:cargo_shipping_rates_per_method]["price_"+weight.to_s].to_f
              detail = Spree::CargoDetailShippingRatesPerMethod.new
              detail.price = price
              detail.cargo_shipping_rates_per_method = @cargo_shipping_rates_per_method
              detail.weight = weight
              detail.save
            end
          end
          flash[:notice] = Spree.t('shipping_rates_per_method_successfully_created')
          redirect_to admin_cargo_shipping_rates_per_methods_path(shipping_method_id: @cargo_shipping_rates_per_method.shipping_method_id)
        else
          flash[:error] = @cargo_shipping_rates_per_method.errors.full_messages.join(", ")
          render :new
        end
      end

      def update
        @cargo_shipping_rates_per_method = Spree::CargoShippingRatesPerMethod.find_by_id params[:id]
        if @cargo_shipping_rates_per_method.update_attributes(cargo_shipping_rates_per_method_params)
          # byebug
          for weight in 1..50 do
            price = params[:cargo_shipping_rates_per_method]["price_"+weight.to_s].to_f
            detail = @cargo_shipping_rates_per_method.cargo_detail_shipping_rates_per_methods.find_by_weight(weight)
            if detail
              # puts "A "+price.to_s
              detail.price = price
            else
              # puts "B"+price.to_s
              detail = Spree::CargoDetailShippingRatesPerMethod.new
              detail.price = price
              detail.cargo_shipping_rates_per_method = @cargo_shipping_rates_per_method
              detail.weight = weight
            end
            detail.save(validate: false)
          end
          flash[:notice] = Spree.t('shipping_rates_per_method_successfully_updated')
          redirect_to admin_cargo_shipping_rates_per_methods_path(shipping_method_id: @cargo_shipping_rates_per_method.shipping_method_id)
        else
          flash[:error] = @cargo_shipping_rates_per_method.errors.full_messages.join(", ")
          render :new
        end
      end

      private

      def cargo_shipping_rates_per_method_params
        params.require(:cargo_shipping_rates_per_method).permit(:country_id, :state_id, :city_id,
                                                                :etd, :shipping_method_id, :adm_price)
      end
    end
  end
end