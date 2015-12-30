class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  scope :for_display, -> {order(created_at: :desc)}
end
