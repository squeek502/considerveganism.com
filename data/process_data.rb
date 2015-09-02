# notes:
#  when creating a new key, duplicate an existing hash so that we still get the dot notation that the yaml-parsed data has

def process_usa_slaughter_data(data)
  # generate layer hen totals using monthly data
  data.slaughter.usa.chickens.layers.sold["total_2013"] = data.slaughter.usa.chickens.layers.sold.by_month_2013.values.inject(:+)
  data.slaughter.usa.chickens.layers.sold["total_2014"] = data.slaughter.usa.chickens.layers.sold.by_month_2014.values.inject(:+)
  data.slaughter.usa.chickens.layers.disappeared["total_2013"] = data.slaughter.usa.chickens.layers.disappeared.by_month_2013.values.inject(:+)
  data.slaughter.usa.chickens.layers.disappeared["total_2014"] = data.slaughter.usa.chickens.layers.disappeared.by_month_2014.values.inject(:+)
  data.slaughter.usa.chickens.layers.pullets_added["total_2013"] = data.slaughter.usa.chickens.layers.pullets_added.by_month_2013.values.inject(:+)
  data.slaughter.usa.chickens.layers.pullets_added["total_2014"] = data.slaughter.usa.chickens.layers.pullets_added.by_month_2014.values.inject(:+)
  data.slaughter.usa.chickens.layers["total_2013"] = data.slaughter.usa.chickens.layers.sold.total_2013 + data.slaughter.usa.chickens.layers.disappeared.total_2013
  data.slaughter.usa.chickens.layers["total_2014"] = data.slaughter.usa.chickens.layers.sold.total_2014 + data.slaughter.usa.chickens.layers.disappeared.total_2014

  # for every pullet added, a male chick was presumably hatched
  data.slaughter.usa.chickens.layers["male_chicks"] = data.slaughter.usa.chickens.layers.dup.clear
  data.slaughter.usa.chickens.layers.male_chicks["total_2013"] = data.slaughter.usa.chickens.layers.pullets_added.total_2013
  data.slaughter.usa.chickens.layers.male_chicks["total_2014"] = data.slaughter.usa.chickens.layers.pullets_added.total_2014

  # get total dairy cows slaughtered, as only the inspected slaughter data is broken into classifications
  data.slaughter.usa.cattle.dairy_cows["percent_of_total_2014"] = data.slaughter.usa.cattle.dairy_cows.total_inspected_2014 / (data.slaughter.usa.cattle.total_inspected_2014 - data.slaughter.usa.cattle.veal_calves.total_inspected_2014).to_f
  data.slaughter.usa.cattle.dairy_cows["percent_of_total_2013"] = data.slaughter.usa.cattle.dairy_cows.total_inspected_2013 / (data.slaughter.usa.cattle.total_inspected_2013 - data.slaughter.usa.cattle.veal_calves.total_inspected_2013).to_f
  data.slaughter.usa.cattle.dairy_cows["total_2014"] = (data.slaughter.usa.cattle.dairy_cows.percent_of_total_2014 * data.slaughter.usa.cattle.total_2014).to_i
  data.slaughter.usa.cattle.dairy_cows["total_2013"] = (data.slaughter.usa.cattle.dairy_cows.percent_of_total_2013 * data.slaughter.usa.cattle.total_2013).to_i

  # calculate beef cattle slaughter by excluding dairy and veal
  data.slaughter.usa.cattle["beef_cattle"] = data.slaughter.usa.cattle.dairy_cows.dup.clear
  data.slaughter.usa.cattle.beef_cattle["total_2014"] = data.slaughter.usa.cattle.total_2014 - data.slaughter.usa.cattle.dairy_cows.total_2014
  data.slaughter.usa.cattle.beef_cattle["total_2013"] = data.slaughter.usa.cattle.total_2013 - data.slaughter.usa.cattle.dairy_cows.total_2013

  # get total lambs slaughtered, as only the inspected slaughter data is broken into classifications
  data.slaughter.usa.sheep.lambs["percent_of_total_2014"] = data.slaughter.usa.sheep.lambs.total_inspected_2014 / data.slaughter.usa.sheep.total_inspected_2014.to_f
  data.slaughter.usa.sheep.lambs["percent_of_total_2013"] = data.slaughter.usa.sheep.lambs.total_inspected_2013 / data.slaughter.usa.sheep.total_inspected_2013.to_f
  data.slaughter.usa.sheep.lambs["total_2014"] = (data.slaughter.usa.sheep.lambs.percent_of_total_2014 * data.slaughter.usa.sheep.total_2014).to_i
  data.slaughter.usa.sheep.lambs["total_2013"] = (data.slaughter.usa.sheep.lambs.percent_of_total_2013 * data.slaughter.usa.sheep.total_2013).to_i
end

def process_usa_inventory_data(data)
  data.inventory.usa.cattle["dairy_calves_born"] = data.inventory.usa.cattle.dairy_cows.dup
end

def process_fao_slaughter_data()
  require 'CSV'

  parsed_data = {}
  unique_items = {}
  world_data = {}
  area_name_index = 3
  item_name_index = 7
  year_index = 8
  unit_index = 9
  value_index = 10
  did_pass_column_names = false
  CSV.foreach("#{config[:data_dir]}/fao-slaughter-data.csv") do |row|
    if not did_pass_column_names then
      did_pass_column_names = true
      next
    end
    if row.length < value_index then 
      next 
    end
    area_name = row[area_name_index]
    item_name = row[item_name_index]

    # combine a few categories
    if item_name == 'Meat, other camelids' || item_name == 'Meat, camel'
      item_name = 'Meat, camel and other camelids'
    elsif item_name == 'Meat, ass' || item_name == 'Meat, mule'
      item_name = 'Meat, ass and mule'
    end

    year = row[year_index].to_i
    unit = row[unit_index]
    value = row[value_index].to_f

    # trim trailing .0's of value
    i, f = value.to_i, value.to_f
    value = i == f ? i : f

    if unit == '1000 Head' then
      value = value * 1000
      unit = 'Head'
    end

    parsed_data[year] ||= {}
    parsed_data[year][area_name] ||= {}
    parsed_data[year][area_name][item_name] ||= {}
    parsed_data[year][area_name][item_name][:unit] = unit
    parsed_data[year][area_name][item_name][:value] = value
    parsed_data[year][area_name][:total] ||= 0
    parsed_data[year][area_name][:total] += value

    unique_items[year] ||= []
    unique_items[year] << item_name unless item_name.in? unique_items[year]

    world_data[year] ||= {}
    world_data[year][item_name] ||= 0
    world_data[year][item_name] += value
    world_data[year][:total] ||= 0
    world_data[year][:total] += value
  end

  world_data.each do |year, data|
    data.each do |item_name, value|
      if item_name != :total and value <= 0
        unique_items[year].delete item_name
      end
    end
  end

  return parsed_data, unique_items, world_data
end