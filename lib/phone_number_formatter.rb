module PhoneNumberFormatter
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def format_phone_fields(*attrs)
      self.send :include, InstanceMethods
      self.send :cattr_accessor, :phone_number_fields
      self.send :phone_number_fields=, attrs
      self.send :before_validation, :strip_phone_number_fields
    end
  end

  module InstanceMethods
    private
    def strip_phone_number_fields
      self.class.phone_number_fields.each do |field|
        self.send(field).gsub!(/\D/, '') unless phone.blank?
      end
    end
  end
end
