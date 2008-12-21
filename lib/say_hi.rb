module SayHi
  CONSTANT = "Hi, you."
  def say_hi
    p CONSTANT
  end
end

ActiveRecord::Base.send(:include, SayHi)
p "Included."
