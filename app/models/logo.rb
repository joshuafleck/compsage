class Logo < ActiveRecord::Base
  
  belongs_to :organization
  
  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :max_size => 10.megabytes,
                 :resize_to => '500x500>',
                 :thumbnails => {
                   :tiny_thumbnail => '50x25>',
                   :standard_thumbnail => '100x50>',
                   :large_thumbnail => '200x100>'
                 },
                 :processor => 'ImageScience'

  validates_as_attachment
  
  validates_presence_of :organization
  
  before_thumbnail_saved do |thumbnail|
    thumbnail.organization = thumbnail.parent.organization
  end
  
end
