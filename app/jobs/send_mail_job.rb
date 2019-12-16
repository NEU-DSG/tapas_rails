class SendMailJob
  @queue  =  "mail_users"

  def self.perform(user, subject, content)
    UserMailer.user_email(user, subject, content).deliver
  end
end
