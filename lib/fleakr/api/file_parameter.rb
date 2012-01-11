module Fleakr
  module Api # :nodoc:
    
    # = FileParameter
    #
    # Parameter class to encapsulate file data sent to the Flickr upload API
    #
    class FileParameter
      
      MIME_TYPES = {
        '.jpg' => 'image/jpeg',
        '.png' => 'image/png',
        '.gif' => 'image/gif'
      }

      attr_reader :name
      
      # Create a parameter with name and specified filename
      #
      def initialize(name, filename)
        @name     = name
        @filename = filename
      end
      
      # Discover MIME type by file extension using MIME_TYPES constant
      #
      def mime_type
        MIME_TYPES[File.extname(@filename)]
      end
      
      # File data (from @filename) to pass to the Flickr API
      # 
      def value
        if @filename.respond_to? 'preloaded_image_data'
          @value ||= @filename.preloaded_image_data
        else
          @value ||= File.read(@filename)
        end
      end
      
      # Generate a form representation of this file for upload (as multipart/form-data)
      #
      def to_form
        "Content-Disposition: form-data; name=\"#{self.name}\"; filename=\"#{@filename}\"\r\n" +
        "Content-Type: #{self.mime_type}\r\n" +
        "\r\n" +
        "#{self.value}\r\n"
      end
      
    end
    
  end
end
