class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:mine]
      @posts = current_user.posts
    else
      @posts = Post.includes(:comments, :user).all
    end
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @post = Post.find(params[:id])
    @comments = @post.comments.for_display.all
    @new_comment = @post.comments.new
  end

private
  def post_params
    params.require(:post).permit(:title, :body)
  end
end
