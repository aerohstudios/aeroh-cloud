class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :devices

  def admin?
    self.email.in?(["shivdeepak@gmail.com", "shiv@aeroh.org"])
  end
end
