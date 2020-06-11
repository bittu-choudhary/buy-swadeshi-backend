class BrandController < ApplicationController

  def data
    unless params["version"]
      render json: {
        error: "Parameter missing",
      }, status: :unprocessable_entity and return
    end
    user_version = params["version"].to_i
    updated_data = {}
    updated_data["version"] = 0
    updated_data["categories"] = {}
    updated_data["products"] = {}
    updated_data["companies"] = {}
    Dir["#{Rails.root}/public/data/*.json"].sort.each do |temp_file|
      file = File.open temp_file
      data = JSON.load file
      file.close
      next if data["version"] <= user_version
      updated_data["version"] = data["version"]
      updated_data["categories"] = updated_data["categories"].merge(data["categories"])
      updated_data["products"] = updated_data["products"].merge(data["products"])
      updated_data["companies"] = updated_data["companies"].merge(data["companies"])
    end
    render :json => updated_data
  end
  

end
