module OrganizationsHelper
require 'gd2'
include GD2 

  def retrieve_image(image,widthx,heightx)
  
    path = "public/imagelib/image_cache/" # default image cache directory
    web_path= "/imagelib/image_cache/"     #default image cache URL
    default_image = "public/imagelib/default.jpg"
    
    #If there is a nil image, use a default image
    if image.blank? then
      filepath = default_image
    else
      filepath = image # Path to file
    end
    
    format = filepath.split(".").last # Format - extension
    
    filename = filepath.last.split(".").first # just file name without extension

    #require 'digest/md5'
    digest = Digest::MD5.hexdigest( filepath ) # md5 hash
    #Generate the name of the cached image file
    cachefile = digest + "-" + widthx.to_s + heightx.to_s + "." + format

    picfile = filepath
    cachedpicfile = path + cachefile
   
    #Check to see if the cached file exists, and is newer than the orginal file
    if File.exists?(cachedpicfile) && (File.stat( cachedpicfile ).mtime.to_i > File.stat( picfile ).mtime.to_i)
      picsource = cachedpicfile
      cache = true
    elsif File.exists? picfile 
      picsource = picfile
    end
   

    if !cache then # Import an image
      i = Image.import(picsource)
     
      if i.size[0] > i.size[1]  # Horizontal proportion. width > height.
        if i.size[0] < widthx then width = i.size[0]     # preffer smaller image width
        else width = widthx
        end
       
        height = width * i.size[1] / i.size[0]
        
      else                      # Vertical proportions
        if i.size[1] < heightx then height = i.size[1]
        else height = heightx
        end
        
        width = i.size[0] /(i.size[1] / height) 
      end
     
      i.resize! width, height
     
      i.export(cachedpicfile) # export cache file
    end
    
    return web_path + cachefile
  	
  end

end
