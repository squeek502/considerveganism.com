# notes:
#  when creating a new key, duplicate an existing hash so that we still get the dot notation that the yaml-parsed data has

def process_slaughter_data(data)
  # generate layer hen totals using monthly data
  data.slaughter.chickens.layers.sold["total_2013"] = data.slaughter.chickens.layers.sold.by_month_2013.values.inject(:+)
  data.slaughter.chickens.layers.sold["total_2014"] = data.slaughter.chickens.layers.sold.by_month_2014.values.inject(:+)
  data.slaughter.chickens.layers.disappeared["total_2013"] = data.slaughter.chickens.layers.disappeared.by_month_2013.values.inject(:+)
  data.slaughter.chickens.layers.disappeared["total_2014"] = data.slaughter.chickens.layers.disappeared.by_month_2014.values.inject(:+)
  data.slaughter.chickens.layers.pullets_added["total_2013"] = data.slaughter.chickens.layers.pullets_added.by_month_2013.values.inject(:+)
  data.slaughter.chickens.layers.pullets_added["total_2014"] = data.slaughter.chickens.layers.pullets_added.by_month_2014.values.inject(:+)
  data.slaughter.chickens.layers["total_2013"] = data.slaughter.chickens.layers.sold.total_2013 + data.slaughter.chickens.layers.disappeared.total_2013
  data.slaughter.chickens.layers["total_2014"] = data.slaughter.chickens.layers.sold.total_2014 + data.slaughter.chickens.layers.disappeared.total_2014

  # for every pullet added, a male chick was presumably hatched
  data.slaughter.chickens.layers["male_chicks"] = data.slaughter.chickens.layers.dup.clear
  data.slaughter.chickens.layers.male_chicks["total_2013"] = data.slaughter.chickens.layers.pullets_added.total_2013
  data.slaughter.chickens.layers.male_chicks["total_2014"] = data.slaughter.chickens.layers.pullets_added.total_2014

  # get total dairy cows slaughtered, as only the inspected slaughter data is broken into classifications
  data.slaughter.cattle.dairy_cows["percent_of_total_2014"] = data.slaughter.cattle.dairy_cows.total_inspected_2014 / (data.slaughter.cattle.total_inspected_2014 - data.slaughter.cattle.veal_calves.total_inspected_2014).to_f
  data.slaughter.cattle.dairy_cows["percent_of_total_2013"] = data.slaughter.cattle.dairy_cows.total_inspected_2013 / (data.slaughter.cattle.total_inspected_2013 - data.slaughter.cattle.veal_calves.total_inspected_2013).to_f
  data.slaughter.cattle.dairy_cows["total_2014"] = (data.slaughter.cattle.dairy_cows.percent_of_total_2014 * data.slaughter.cattle.total_2014).to_i
  data.slaughter.cattle.dairy_cows["total_2013"] = (data.slaughter.cattle.dairy_cows.percent_of_total_2013 * data.slaughter.cattle.total_2013).to_i

  # calculate beef cattle slaughter by excluding dairy and veal
  data.slaughter.cattle["beef_cattle"] = data.slaughter.cattle.dairy_cows.dup.clear
  data.slaughter.cattle.beef_cattle["total_2014"] = data.slaughter.cattle.total_2014 - data.slaughter.cattle.dairy_cows.total_2014
  data.slaughter.cattle.beef_cattle["total_2013"] = data.slaughter.cattle.total_2013 - data.slaughter.cattle.dairy_cows.total_2013
end

def process_inventory_data(data)
  data.inventory.cattle["dairy_calves_born"] = data.inventory.cattle.dairy_cows.dup
end