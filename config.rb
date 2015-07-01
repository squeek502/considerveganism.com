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

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end
