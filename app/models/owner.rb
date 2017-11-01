class Owner < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :properties

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
