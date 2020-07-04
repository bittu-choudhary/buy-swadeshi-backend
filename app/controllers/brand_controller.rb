class BrandController < ApplicationController
  before_action :load_data, only: [:product, :company, :category]

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

  def product
    pid = params["pid"]
    p pid
    product_obj = @data["products"][pid]
    product_obj["alt_products"] = {}
    product_obj["categories"].each do |key, value|
      if value["isParent"] && product_obj["alt_products"].length < 10
        category_products = @data["categories"][key]["products"]
        category_products.each do |key, value|
          next if (key == pid || !value["isIndian"])
          product_obj["alt_products"][key] = value
          break if product_obj["alt_products"].length == 10
        end
      end
    end
    p product_obj["alt_products"].length
    render :json => product_obj

  end
  
  def company
    cid = params["cid"]
    company_obj = @data["companies"][cid]
    company_obj["alt_companies"] = {}
    company_obj["categories"].each do |key, value|
      if value["isParent"] && company_obj["alt_companies"].length < 10
        category_products = @data["categories"][key]["companies"]
        category_products.each do |key, value|
          next if (key == cid || !value["isIndian"])
          company_obj["alt_companies"][key] = value
          break if company_obj["alt_companies"].length == 10
        end
      end
    end
    render :json => company_obj
  end

  def category
    cat_id = params["catid"]
    render :json => @data["categories"][cat_id]
  end
  

  private

  def load_data
    file = File.open "#{Rails.root}/public/data/brand_data_v1.json"
    @data = JSON.load file
    file.close
  end
  
  

end
