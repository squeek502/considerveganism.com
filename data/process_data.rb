def process_slaughter_data(data)
  data.slaughter.layer_hens.sold["total_2013"] = data.slaughter.layer_hens.sold.by_month_2013.values.inject(:+)
  data.slaughter.layer_hens.sold["total_2014"] = data.slaughter.layer_hens.sold.by_month_2014.values.inject(:+)
  data.slaughter.layer_hens.disappeared["total_2013"] = data.slaughter.layer_hens.disappeared.by_month_2013.values.inject(:+)
  data.slaughter.layer_hens.disappeared["total_2014"] = data.slaughter.layer_hens.disappeared.by_month_2014.values.inject(:+)
  data.slaughter.layer_hens.pullets_added["total_2013"] = data.slaughter.layer_hens.pullets_added.by_month_2013.values.inject(:+)
  data.slaughter.layer_hens.pullets_added["total_2014"] = data.slaughter.layer_hens.pullets_added.by_month_2014.values.inject(:+)
  data.slaughter.layer_hens["died"] = data.slaughter.layer_hens.sold.dup.clear
  data.slaughter.layer_hens.died["total_2013"] = data.slaughter.layer_hens.sold.total_2013 + data.slaughter.layer_hens.disappeared.total_2013
  data.slaughter.layer_hens.died["total_2014"] = data.slaughter.layer_hens.sold.total_2014 + data.slaughter.layer_hens.disappeared.total_2014

  data.slaughter["male_chicks"] = data.slaughter.layer_hens.dup.clear
  data.slaughter.male_chicks["total_2013"] = data.slaughter.layer_hens.pullets_added.total_2013
  data.slaughter.male_chicks["total_2014"] = data.slaughter.layer_hens.pullets_added.total_2014
end