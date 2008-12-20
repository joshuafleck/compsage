module StatisticsExtension
  def percentiles(field, *percentiles)
    data = self.collect{|r| r.send(field) || 0 }
    return nil if data.empty?
    return Array.new(percentiles.size, data.first) if data.size == 1
    data.sort!
    size = data.size
    results = []
    
    # To calculate the percentile, we first figure out exactly where in the range of numbers we fall.  We then take
    # that position and find out what array index that corresponds to.  Next, we take the difference between the array
    # position and the actual position to determine a weight by which we must adjust the percentile to get a more
    # accurate representation of the data (assuming our chosen position isn't already the largest data element).
   
    percentiles.each do |percentile|
      pos = (size-1) * (percentile/100.0)
      index = pos.to_i
      weight = pos - index
      
      result = data[index]
      result = result * (1-weight) + data[index + 1] * weight if index < size - 1
      results << result
    end
    
    results
  end
end
