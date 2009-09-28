# Fix for relative paths when ActionMailer is looking for view templates. Remove after upgrading
#  to next rails version (> 2.3.2)
# https://rails.lighthouseapp.com/projects/8994/tickets/2263-rails-232-breaks-implicit-multipart-actionmailer-tests
module ActionMailer
  class Base
    def template_path
      File.join(template_root, mailer_name)
    end
  end
end
