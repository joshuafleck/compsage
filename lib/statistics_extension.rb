module StatisticsExtension
  # Percentiles calculated based on NIST recommended algorithm.
  # Returns nil if there is no data to calculate percentiles with.
  def percentiles(field, *percentiles)
    data = self.collect{|r| r.send(field) || 0 }
    return nil if data.empty?
    return Array.new(percentiles.size, data.first) if data.size == 1

    data.sort!
    size = data.size
    results = []
    
    percentiles.each do |percentile|
      p  = percentile / 100.0
      kd = p  * (size + 1)
      k  = kd.to_i
      d  = kd - k

      if k == 0 then
        results << data.first
      elsif k >= size
        results << data.last
      else
        results << data[k-1] + d * (data[k] - data[k-1])
      end
    end
    
    results
  end
end
