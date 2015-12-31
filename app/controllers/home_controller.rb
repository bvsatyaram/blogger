class HomeController < ApplicationController
  def dashboard
    @leader_board = User.leader_board
  end
end
