module Authentication
  unless defined? CONSTANTS_DEFINED
    # Uncomment to suit
    RE_LOGIN_OK     = /\A\w[\w\.\-_@]+\z/                     # ASCII, strict
    # RE_LOGIN_OK   = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/     # Unicode, strict
    # RE_LOGIN_OK   = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
    MSG_LOGIN_BAD   = "use only letters, numbers, and .-_@ please."

    RE_NAME_OK      = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
    MSG_NAME_BAD    = "avoid non-printing characters and \\&gt;&lt;&amp;/ please."

    RE_EMAIL_OK     = /\A[A-Za-z0-9!#$\%&'*+\/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$\%&'*+\/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\Z/
    MSG_EMAIL_BAD   = "isn't formatted properly"
    
    CONSTANTS_DEFINED = 'yup' # sorry for the C idiom
  end
  
  def self.included( recipient )
    recipient.extend( ModelClassMethods )
    recipient.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('--'))
    end
    def make_token
      secure_digest(Time.now, (1..10).map{ rand.to_s })
    end 
  end # class methods
  
  module ModelInstanceMethods
  end # instance methods

end
