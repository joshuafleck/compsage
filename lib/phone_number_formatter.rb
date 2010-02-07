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

      attrs.each do |a|
        define_method "formatted_#{a}" do
          phone = self.send(a)

          return nil if phone.nil?

          return "#{phone[0, 3]}-#{phone[3, 3]}-#{phone[6, 4]}"
        end
      end
    end
  end

  module InstanceMethods
    private
    def strip_phone_number_fields
      self.class.phone_number_fields.each do |field|
        self.send(field).gsub!(/\D/, '') unless self.send(field).blank?
      end
    end
  end
end
