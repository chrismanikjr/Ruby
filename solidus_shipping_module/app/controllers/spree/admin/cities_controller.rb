module Spree
  module Admin
    class CitiesController < ResourceController
      def import
        City.import(params[:file])
        redirect_to admin_cities_path, notice: "Cities imported."
      end
    end
  end
end
