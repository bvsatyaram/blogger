# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :posts
  has_many :comments

  def posts_count
   self.posts.count
  end

  def outgoing_comments_count
    self.comments.select do |comment|
      comment.post.user != self
    end.count
  end

  def incoming_comments_count
    self.posts.collect do |post|
      post.comments.select do |comment|
        comment.user != self
      end.count
    end.reduce(:+)
  end

  def score
    return 10*self.posts_count + 3*self.outgoing_comments_count + self.incoming_comments_count
  end
end
