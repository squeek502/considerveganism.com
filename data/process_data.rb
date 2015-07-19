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