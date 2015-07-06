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
      :reddit => "https://www.reddit.com/submit?url=#{CGI.escape(external_url)}&title=#{CGI.escape(title)}"
      # facebook doesn't have support for plain link image sharing via URL
    }
  end

  def share_link_to(url, title, description)
    share_links = {
      :facebook => "https://www.facebook.com/sharer/sharer.php?u=#{CGI.escape(url)}",
      :twitter => "https://twitter.com/intent/tweet?url=#{CGI.escape(url)}&text=#{CGI.escape(title)}",
      :googleplus => "https://plus.google.com/share?url=#{CGI.escape(url)}",
      :tumblr => "https://www.tumblr.com/widgets/share/tool?posttype=link&content=#{CGI.escape(url)}&title=#{CGI.escape(title)}&caption=#{CGI.escape(description)}",
      :reddit => "https://www.reddit.com/submit?url=#{CGI.escape(url)}&title=#{CGI.escape(title)}"
    }
  end
end
