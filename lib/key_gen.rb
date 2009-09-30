module KeyGen
  # These characters are said to be url-safe as per RFC 3986
  URL_SAFE_CHARS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

  # Construct a random url-safe key of the specified length.
  def self.random(length = 10)
    return Array.new(length){ URL_SAFE_CHARS[rand(66)] }.join
  end
end
