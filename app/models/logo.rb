class Logo < ActiveRecord::Base
  
  belongs_to :organization
  belongs_to :association
  
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

  validates_presence_of :organization, :if => lambda { |l| l.association.nil? }
  validates_presence_of :association, :if => lambda { |l| l.organization.nil? }
  validates_as_attachment
  
  before_thumbnail_saved do |thumbnail|
    thumbnail.organization = thumbnail.parent.organization
  end
  
end
