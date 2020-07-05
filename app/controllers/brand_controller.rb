class BrandController < ApplicationController
  before_action :load_data, only: [:product, :company, :category, :staging]

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

  def staging
    render :json => @data
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
          product_obj["alt_products"][key]["company"] = @data["products"][key]["company"]
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
    company_obj["categories"].each do |cat_key, cat_value|
      if cat_value["isParent"] && company_obj["alt_companies"].length < 10
        category_companies = @data["categories"][cat_key]["companies"]
        category_companies.each do |com_key, com_value|
          next if (com_key == cid || !com_value["isIndian"])
          company_obj["alt_companies"][com_key] = com_value
          company_obj["alt_companies"][com_key]["parent_category"] = cat_key
          break if company_obj["alt_companies"].length == 10
        end
      end
    end
    render :json => company_obj
  end

  def category
    cat_id = params["catid"]
    cid = params["cid"] == "undefined" ? false : params["cid"]
    is_indian = params["isIndian"] == "undefined" ? false : true
    allc = params["allc"] == "undefined" ? false : true
    category_obj = @data["categories"][cat_id]
    products = []
    if cid
      @data["companies"][cid]["products"].each do |key, value|
        next unless @data["products"][key]["categories"][cat_id]
        products << value
      end
    else
      if is_indian
        if allc
          category_obj["companies"].each do |key, value|
            next unless value["isIndian"]
            products << value
          end
        else
          category_obj["products"].each do |key, value|
            next unless value["isIndian"]
            products << value
          end
        end
      elsif allc
        category_obj["companies"].each do |key, value|
          products << value
        end
      else
        category_obj["products"].each do |key, value|
          products << value
        end
      end
    end
    category_obj["products"] = products
    render :json => category_obj
  end

  def indexed_data
    file = File.open "#{Rails.root}/public/data/indexed_data.json"
    indexed_data = JSON.load file
    file.close
    render :json => indexed_data
  end


  private

  def load_data
    file = File.open "#{Rails.root}/public/data/brand_data_v0.json"
    @data = JSON.load file
    file.close
  end



end
