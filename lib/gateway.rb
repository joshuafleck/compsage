module Gateway
  class << self
    attr_accessor :gateway
  end
  
  # Authorizes the withdrawal and stores the auth code for later.
  def self.sponsor_survey(survey, credit_card)
    response = authorize(survey.price, credit_card)
    survey.billing_authorization = response.authorization
    
    # TODO: Verify that this is actually what the name of this param is from Authorize.net
    survey.authorization_transaction_id = response.params['transaction_id']
  end 

  # Bills the sponsor for the specified survey.
  def self.bill_survey_sponsor(survey)
    response = capture(survey.price, survey.billing_authorization)

    # TODO: Verify that these are correct param names.
    survey.capture_transaction_id = response.params['transaction_id']
    survey.capture_authorization_code = response.params['authorization_code']
  end

  # Voids the authorization to charge for the specified survey.
  def self.void_survey(survey)
    response = void(Survey.authorization_transaction_id)
    survey.void_transaction_id = response.params['transaction_id']
    survey.void
  end

  # Authorizes a transaction.  Raises an exception when an error occurs, such as incorrect billing information.
  def self.authorize(money, credit_card)
    response = @gateway.authorize(money, credit_card)
    
    if response.success? then
      response
    else
      raise Exceptions::GatewayException, response.message
    end
  end
  
  # Captures money for the specified authorization.  Raises an exception when an error occurs, such as declined?
  # Not sure if that's possible, but at any rate, we should handle these exceptions in our controllers.
  def self.capture(money, auth)
    response = @gateway.capture(money, auth)
    
    if response.success? then
      return response
    else
      raise Exceptions::GatewayException, response.message
    end
  end
 
  # voids the specified transaction.  Not worrying about exceptions at this time.
  def self.void(trans)
    @gateway.void(trans)
  end
end
