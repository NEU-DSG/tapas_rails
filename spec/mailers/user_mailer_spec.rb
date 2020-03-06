require "spec_helper"

describe UserMailer do
  it 'sends mail' do
    skip "Test passes locally but not on Travis." if ENV['TRAVIS']

    user = FactoryBot.create :user
    email = UserMailer.user_email(user, 'Test Subject', 'Test Content')
    assert_emails 1 do
      email.deliver
    end

    expect(email.to).to eq [user.email]
    expect(email.subject).to eq 'Test Subject'
  end
end
