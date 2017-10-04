class UserMailer < ActionMailer::Base
  default from: "tapas@neu.edu"

  def user_email(user, subject, content)
    @user = user
    @subject = subject
    @content = content
    mail(to: @user.email, subject: @subject)
  end
end
