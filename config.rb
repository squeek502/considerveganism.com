###
# General settings
###

activate :directory_indexes

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :development do
  activate :livereload, :host => '127.0.0.1'
end

configure :build do
  activate :minify_css
  activate :minify_javascript
end

page "data/*", :layout => :data_layout

set :domain, 'http://considerveganism.com'

###
# Blog settings
###

# Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "blog_article"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "blog/tag.html"
  blog.calendar_template = "blog/calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"
end

page "/feed.xml", layout: false

configure :development do
  set :feed_url, "/feed.xml"
end
configure :build do
  set :feed_url, "http://feeds.feedburner.com/ConsiderVeganism"
end

###
# World slaughter data
###
load "#{config[:data_dir]}/process_data.rb"
load "#{config[:helpers_dir]}/fao_country_codes.rb"
helpers FaoCountryCodes
@slaughter_data, @slaughter_categories, @world_data = process_fao_slaughter_data()
first_year = 1961
last_year = 2013

for year in first_year..last_year
  locals = { 
    :year => year, 
    :slaughter_data => @slaughter_data[year], 
    :slaughter_categories => @slaughter_categories[year], 
    :world_data => @world_data[year]
  }
  proxy("/data/world-slaughter/#{year}/index.html", "/data/world-slaughter/year.html", :locals => locals, :ignore => true)
  proxy("/data/world-slaughter/#{year}.csv", "/data/world-slaughter/year.csv", :locals => locals, :ignore => true)
end

unique_countries = {}
@slaughter_data.each do |year, countries|
  countries.each do |country, data|
    country_code = fao_to_iso3166_code country
    unique_countries[country_code] ||= []
    unique_countries[country_code] << country unless country.in? unique_countries[country_code]
  end
end

slaughter_data_by_country = {}
unique_countries.each do |country_code, countries|
  for year in first_year..last_year do
    matching_country_names = @slaughter_data[year].keys & countries
    if not matching_country_names.any? then
      next
    end
    year_data = {}
    matching_country_names.each do |matching_country_name|
      year_data[matching_country_name] = @slaughter_data[year][matching_country_name]
    end
    slaughter_data_by_country[country_code] ||= {}
    slaughter_data_by_country[country_code][year] = year_data
  end
end

slaughter_data_country_codes = slaughter_data_by_country.keys
slaughter_data_by_country.each do |country_code, country_data|
  country_code_index = slaughter_data_country_codes.index country_code
  locals = { 
    :countries => unique_countries[country_code],
    :country_code => country_code, 
    :slaughter_data => country_data, 
    :slaughter_categories => @slaughter_categories, 
    :world_data => @world_data
  }
  locals[:next_country] = slaughter_data_country_codes[country_code_index + 1] if country_code_index < slaughter_data_country_codes.length
  locals[:prev_country] = slaughter_data_country_codes[country_code_index - 1] if country_code_index > 0
  proxy("/data/world-slaughter/#{country_code.downcase}/index.html", "/data/world-slaughter/country.html", :locals => locals, :ignore => true)
  proxy("/data/world-slaughter/#{country_code.downcase}.csv", "/data/world-slaughter/country.csv", :locals => locals, :ignore => true)
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do
  def absolute_url(relative_url)
    config[:domain] + "/" + (relative_url[0] == '/' ? relative_url[1..-1] : relative_url)
  end

  def share_image_to(external_url, internal_url, title, description)
    share_links = {
      :twitter => "https://twitter.com/intent/tweet?url=#{CGI.escape(external_url)}&text=#{CGI.escape(title)}",
      :googleplus => "https://plus.google.com/share?url=#{CGI.escape(external_url)}",
      :tumblr => "https://www.tumblr.com/widgets/share/tool?posttype=photo&content=#{CGI.escape(external_url)}&caption=#{CGI.escape(title)}&canonicalUrl=#{CGI.escape(absolute_url("/"))}",
      :reddit => "https://www.reddit.com/submit?url=#{CGI.escape(external_url)}&title=#{CGI.escape(title)}",
      :vk => "http://vk.com/share.php?url=#{CGI.escape(external_url)}"
      # facebook doesn't have support for plain link image sharing via URL
    }
  end

  def share_link_to(url, title, description)
    share_links = {
      :facebook => "https://www.facebook.com/sharer/sharer.php?u=#{CGI.escape(url)}",
      :twitter => "https://twitter.com/intent/tweet?url=#{CGI.escape(url)}&text=#{CGI.escape(title)}",
      :googleplus => "https://plus.google.com/share?url=#{CGI.escape(url)}",
      :tumblr => "https://www.tumblr.com/widgets/share/tool?posttype=link&content=#{CGI.escape(url)}&canonicalUrl=#{CGI.escape(url)}&title=#{CGI.escape(title)}&caption=#{CGI.escape(description)}",
      :reddit => "https://www.reddit.com/submit?url=#{CGI.escape(url)}&title=#{CGI.escape(title)}",
      :vk => "http://vk.com/share.php?url=#{CGI.escape(url)}"
    }
  end

  @should_include_googlechart = false

  def needs_googlechart()
    return @should_include_googlechart
  end

  def uses_googlechart()
    @should_include_googlechart = true
  end
end
