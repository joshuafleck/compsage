class Units
  attr_accessor :name, :values, :standard_unit

  # Create a new set of units.
  #
  # * Name is what the units are of, such as payment terms or currency.
  # * Units is a hash of unit names and the number of those units in a normalized unit. For example, if you wanted to
  #   store distances in the database, you might define units to be {'Miles' => 1, 'Kilometers' => 1.609334}.
  # * Standard is the name of the normal unit.
  #
  def initialize(name, values, standard)
    @name = name
    @values = values
    @standard_unit = standard
  end

  # Converts between units. Options must include :from and :to.
  def convert(value, options)
    from = options.delete(:from)
    to = options.delete(:to)
    raise ArgumentError.new("Unit #{from} or #{to} not found") unless @values.has_key?(from) && @values.has_key?(to)

    return value * (@values[from] / @values[to].to_f)
  end

  def form_values
    @values.keys
  end
end
