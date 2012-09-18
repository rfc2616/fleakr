module Fleakr
  module Objects # :nodoc:

    # = Set
    #
    # == Attributes
    #
    # [id] The ID for this photoset
    # [title] The title of this photoset
    # [description] The description of this set
    # [count] Count of photos in this set
    #
    # == Associations
    #
    # [photos] The collection of photos for this set. See Fleakr::Objects::Photo
    # [comments] All comments associated with this set. See Fleakr::Objects::Comment
    #
    class Set

      include Fleakr::Support::Object

      has_many :photos, :comments

      flickr_attribute :id, :title, :description
      flickr_attribute :primary_photo_id, :from => '@primary'
      flickr_attribute :count, :from => '@photos'
      flickr_attribute :user_id, :from => '@owner'

      find_all :by_user_id, :call => 'photosets.getList', :path => 'photosets/photoset'

      find_one :by_id, :using => :photoset_id, :call => 'photosets.getInfo', :path => 'photoset'

      lazily_load :user_id, :with => :load_info

      # Save all photos in this set to the specified directory for the specified size.  Allowed
      # Sizes include <tt>:square</tt>, <tt>:small</tt>, <tt>:thumbnail</tt>, <tt>:medium</tt>,
      # <tt>:large</tt>, and <tt>:original</tt>.  When saving the set, this method will create
      # a subdirectory based on the set's title.
      #
      def save_to(path, size)
        target = "#{path}/#{folder_name}"
        FileUtils.mkdir(target) unless File.exist?(target)

        photos.each_with_index do |photo, index|
          image = photo.send(size)
          image.save_to(target, file_prefix(index)) unless image.nil?
        end
      end

      def file_prefix(index) # :nodoc:
        sprintf("%0#{count.length}d_", (index + 1))
      end

      def folder_name # :nodoc:
        title.gsub("/", ' ').squeeze(' ')
      end

      # Primary photo for this set. See Fleakr::Objects::Photo for more details.
      #
      def primary_photo(options = {})
        with_caching(options, 'primary_photo') do
          Photo.find_by_id(primary_photo_id, authentication_options.merge(options))
        end
      end

      # The URL for this set.
      #
      def url
        "http://www.flickr.com/photos/#{user_id}/sets/#{id}/"
      end

      # The user who created this set.
      #
      def user(options = {})
        with_caching(options, 'user') do
          User.find_by_id(user_id, authentication_options.merge(options))
        end
      end

      def load_info # :nodoc:
        options  = authentication_options.merge(:photoset_id => id)
        response = Fleakr::Api::MethodRequest.with_response!('photosets.getInfo', options)

        populate_from(response.body)
      end

      def self.create( options = {} )
        response = Fleakr::Api::MethodRequest.with_response!( 'photosets.create', options )
        photoset = Set.new( response.body )
        Set.find_by_id( photoset.id )
      end

      def add_photo( options = {} )
        options = options.merge( :photoset_id => id )
        Fleakr::Api::MethodRequest.with_response!( 'photosets.addPhoto', options )
      end

    end
  end
end
