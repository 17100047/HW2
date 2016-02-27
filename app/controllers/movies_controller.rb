class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    @all_ratings = Movie.all_ratings
    @ratings =  {"G" => "1", "PG" => "1", "PG-13" => "1", "R" => "1", "NC-17" => "1"} 
    if params[:ratings].nil? && params[:sort_by].nil?
      session[:ratings] = @ratings
      session[:sort_by] = nil
    end

    if session.has_key?(:ratings) && params.has_key?(:sort_by)
      session[:sort_by] = params[:sort_by]
      @ratings = session[:ratings]
      @movies = Movie.where(rating: @ratings.keys).order(params[:sort_by])
      if params[:sort_by] == 'title'
        @title_header = 'hilite'
      elsif params[:sort_by] == 'release_date'
        @release_header ='hilite'
      end
    elsif session.has_key?(:sort_by) && params.has_key?(:ratings)
      @ratings = params[:ratings]
      session[:ratings] = @ratings
      @movies = Movie.where(rating: @ratings.keys).order(session[:sort_by])
      if session[:sort_by] == 'title'
        @title_header = 'hilite'
      elsif session[:sort_by] == 'release_date'
        @release_header ='hilite'
      end
    elsif session[:ratings].nil? && params.has_key?(:sort_by)
      session[:sort_by] = params[:sort_by]
      @movies = Movie.order(params[:sort_by])
      if params[:sort_by] == 'title'
        @title_header = 'hilite'
      elsif params[:sort_by] == 'release_date'
        @release_header ='hilite'
      end
    elsif session[:sort_by].nil? && params.has_key?(:ratings)
      @ratings = params[:ratings]
      @movies = Movie.where(rating: @ratings.keys)
      session[:ratings] = @ratings
    else
      @movies = Movie.all
    end
    
    # if params.has_key?(:sort_by)
    #   @movies = Movie.order(params[:sort_by])
    #   if params[:sort_by] == 'title'
    #     @title_header = 'hilite'
    #   elsif params[:sort_by] == 'release_date'
    #     @release_header ='hilite'
    #   end
    # end
    
  end
    
  def new
    # default: render 'new' template
  end

  def deletebyrating
  end

  def deleterating
    i = 0
    Movie.where(rating: params[:movie][:rating]).find_each do |user|
      user.destroy
      i = i + 1
    end
    flash[:notice] = "'#{i}' Movies with rating #{params[:movie][:rating]} were deleted."
    redirect_to movies_path
  end

  def deletebyname
  end

  def deletename
    @movie = Movie.find_by_title(params[:movie][:title])
    if @movie
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    else
      flash[:notice] = "THE MOVIE YOU ENTERED WAS NOT FOUND"
      redirect_to movies_path
    end
  end

  def updatebysearch
  end

  def updateif
    @movie = Movie.find_by_title(params[:oldmovie][:title])
    if @movie
      x = @movie.title
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{x} was successfully updated."
      redirect_to movie_path(@movie)
    else
      flash[:notice] = "THE MOVIE YOU ENTERED WAS NOT FOUND"
      redirect_to movies_path
    end
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
