class User < ApplicationRecord
  include StripeSubscribable

  devise :database_authenticatable,
    :recoverable, :rememberable, :validatable

end
