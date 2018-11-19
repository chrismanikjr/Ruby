module Spree
  module Admin
    class ShippingRatesPerMethodsController < ResourceController
      def index
        @shipping_method = ShippingMethod.find_by_id params[:shipping_method_id]
        @rates = @shipping_method.shipping_rates_per_methods.filter(params.slice(:city_contain, :province_contain)).page(params[:page]).per(params[:per_page])
      end

      def import
        @shipping_method = ShippingMethod.find_by_id params[:shipping_method_id]
        if ShippingRatesPerMethod.import(params[:file], params[:shipping_method_id])
          redirect_to admin_shipping_rates_per_methods_path(shipping_method_id: @shipping_method.id), notice: "Products imported."
        end
      end

      def create
        @shipping_rates_per_method = Spree::ShippingRatesPerMethod.new(shipping_rates_per_method_params)
        if @shipping_rates_per_method.save
          flash[:notice] = Spree.t('shipping_rates_per_method_successfully_created')
          redirect_to admin_shipping_rates_per_methods_path(shipping_method_id: @shipping_rates_per_method.shipping_method_id)
        else
          flash[:error] = @shipping_rates_per_method.errors.full_messages.join(", ")
          render :new
        end
      end

      def update
        @shipping_rates_per_method = Spree::ShippingRatesPerMethod.find_by_id params[:id]
        if @shipping_rates_per_method.update_attributes(shipping_rates_per_method_params)
          flash[:notice] = Spree.t('shipping_rates_per_method_successfully_updated')
          redirect_to admin_shipping_rates_per_methods_path(shipping_method_id: @shipping_rates_per_method.shipping_method_id)
        else
          flash[:error] = @shipping_rates_per_method.errors.full_messages.join(", ")
          render :new
        end
      end

      private

      def shipping_rates_per_method_params
        params.require(:shipping_rates_per_method).permit(:country_id, :state_id, :city_id, :price,
          :etd, :min_weight, :shipping_method_id, :adm_price)
      end
    end
  end
end