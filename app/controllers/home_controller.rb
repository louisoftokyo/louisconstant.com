class HomeController < ApplicationController
  before_action :set_locale
  respond_to :json
  
  def set_locale
	I18n.locale = params[:locale] || I18n.default_locale
  end
  
  def get_locale
	respond_with(I18n.locale || I18n.default_locale)
  end
  
  def display
	@photos = Photo.all(:order => "id ASC")
	@rainbowPhotos = Photo.all(:order => "hue ASC")
	
	@locale = I18n.locale
  end
  
  def latest
    @whereResult = Photo.where("album = ?", params[:album])
    if @whereResult.blank?
      @photo = Photo.first
    else    
      @photo = @whereResult.order("id ASC").first
    end   
  respond_with(@photo)
  end

  def getPhoto
    
  @whereResult = Photo.where("filename = ?", params[:photoID])
  if @whereResult.blank?
    @photo = Photo.order("id ASC").first
  else    
    @photo = @whereResult.first
  end
    
  respond_with(@photo)
  end

  def getAlbum
    thumbnailsPath = 'app/assets/images/thumbnails/' + params[:albumName] + '/'
    @imgNames = []

    Dir.foreach(thumbnailsPath) do |file|
      next if file == '.' or file == '..'
      filename = File.basename(file, ".*")
      @imgNames.push(filename)
    end    
    respond_to do |format|
       format.json { render :json => @imgNames }
     end
  end
  
  def previous
  	@whereResult = Photo.
      where("id < ?", params[:clientNum]).
      where("album = ?", params[:album])
  	if @whereResult.blank?
  	  @photo = Photo.order("id DESC").first
  	else	  
  	  @photo = @whereResult.order("id DESC").first
  	end	  
	respond_with(@photo)
  end
   
  def next
  	@whereResult = Photo.
      where("id > ?", params[:clientNum]).
      where("album = ?", params[:album])
  	if @whereResult.blank?
  	  @photo = Photo.first
  	else	  
  	  @photo = @whereResult.order("id ASC").first
  	end	  
	respond_with(@photo)
  end
  
  ######################################################
  
  
  
  ######################################################
  
  def about
  end

  def contact
  end 

  def default_url_options(options={})
    { :locale => I18n.locale }
  end  

end
