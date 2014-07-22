class HomeController < ApplicationController
  before_action :set_locale
  respond_to :json

  @@photosClientPath     = File.join('', 'assets', 'photos')
  @@thumbnailsClientPath = File.join('', 'assets', 'thumbnails')
  @@thumbnailsServerPath = File.join('app', 'assets', 'images', 'thumbnails')
  @@imgExt = '.jpg'
  
  def set_locale
	I18n.locale = params[:locale] || I18n.default_locale
  end
  
  def get_locale
	respond_with(I18n.locale || I18n.default_locale)
  end
  

  def latest
    @whereResult = Photo.where("album = ?", params[:album])
    if @whereResult.blank?
      @photo = Photo.first
    else    
      @photo = @whereResult.order("id ASC").first
    end   
  
  render json: {photo: @photo, path: File.join(@@photosClientPath, @photo.album, @photo.filename + @@imgExt)}
  end

  def photo
    
  @whereResult = Photo.where("filename = ?", params[:photoID]).
        where("album = ?", params[:album])
  if @whereResult.blank?
    @photo = Photo.order("id ASC").first
  else    
    @photo = @whereResult.first
  end

  render json: {photo: @photo, path: File.join(@@photosClientPath, @photo.album, @photo.filename + @@imgExt)}

  end

  def album
    @imgPaths = []
    thumbnails = Dir[File.join(@@thumbnailsServerPath, params[:albumName], '*')].sort_by{ |f| File.mtime(f) }
    puts thumbnails
    thumbnails.each do |file|
      next if file == '.' or file == '..'
      name = File.basename(file, '.*')
      @imgPaths.push(File.join(@@thumbnailsClientPath, params[:albumName], name + @@imgExt))
    end    

    respond_to do |format|
       format.json { render :json => @imgPaths }
     end
  end
  
  def previous
  	@previousPhotos = Photo.
      where("id < ?", params[:clientNum]).
      where("album = ?", params[:album])
  	if @previousPhotos.blank?
  	  @photo = Photo.
      where("album = ?", params[:album]).order("id DESC").first
  	else	  
  	  @photo = @previousPhotos.order("id DESC").first
  	end	  
	render json: {photo: @photo, path: File.join(@@photosClientPath, @photo.album, @photo.filename + @@imgExt)}
  end
   
  def navigate
    forwards = params[:forwards] == "true"
  	@currentPhoto = Photo.where("filename = ?", params[:currentPhoto]).where("album = ?", params[:album]).first
    @newPhoto = Photo.where("id " + ((forwards ? ">" : "<") + " ?"), @currentPhoto.id).order("id " + (forwards ? "ASC" : "DESC")).where("album = ?", @currentPhoto.album).first      
  	if @newPhoto.blank?
       @thisAlbum = Photo.where("album = ?", @currentPhoto.album).order("id ASC")
  	   @newPhoto = forwards ? @thisAlbum.first : @thisAlbum.last
       puts @newPhoto.id
       puts @newPhoto.english_title
  	end	  
	render json: {photo: @newPhoto, path: File.join(@@photosClientPath, @newPhoto.album, @newPhoto.filename + @@imgExt)}
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
