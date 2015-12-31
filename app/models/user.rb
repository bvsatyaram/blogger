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

  def self.leader_board
    users = self.includes({posts: :comments}, :comments)
    data = []
    users.each do |usr|
      usr_data = {}
      usr_data[:email] = usr.email
      usr_data[:posts_count] = usr.posts.size

      usr_data[:incoming_comments_count] = usr.posts.collect do |post|
        post.comments.select do |comment|
          comment.user_id == usr.id
        end.size
      end.reduce(:+)

      usr_data[:outgoing_comments_count] = usr.comments.count do |comment|
        !usr.posts.collect(&:id).include?(comment.post_id)
      end

      score = 0
      score += 10*usr_data[:posts_count]
      score += 3*usr_data[:outgoing_comments_count]
      score += usr_data[:incoming_comments_count]
      usr_data[:score] = score

      data.push(usr_data)
    end

    data.sort_by!{|item| item[:score]}.reverse!

    return data
  end

  # def post_ids
  #   @post_ids ||= self.posts.pluck(:id)
  # end
  #
  # def posts_count
  #  self.post_ids.size
  # end
  #
  # def outgoing_comments_count
  #   @outgoing_comments_count ||= self.comments
  #                                    .where.not(post_id: self.post_ids)
  #                                    .count
  # end
  #
  # def incoming_comments_count
  #   @incoming_comments_count ||= Comment.where.not(user_id: self.id)
  #                                       .where(post_id: self.post_ids)
  #                                       .count
  # end
  #
  # def score
  #   return @score if @score
  #   @score = 0
  #   @score += 10*self.posts_count
  #   @score += 3*self.outgoing_comments_count
  #   @score += self.incoming_comments_count
  #   return @score
  # end
end
