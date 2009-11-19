module URLHelper
  def add_subdomain(url)
    return url.gsub('http://www.example.com', @base_url)
  end
  
end