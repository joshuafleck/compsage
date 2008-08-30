module Exceptions
  class AlreadyInvited < RuntimeError; end
  class AlreadyMember < RuntimeError; end
  class SelfInvitation < RuntimeError; end
  class ExistingOrganization < RuntimeError; end
end
