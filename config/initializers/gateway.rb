Gateway.gateway = ActiveMerchant::Billing::BogusGateway.new(:login => "test", :password => "test")
ActiveMerchant::Billing::Base.mode = :test
