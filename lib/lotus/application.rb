require 'lotus/utils/class_attribute'
require 'lotus/frameworks'
require 'lotus/configuration'
require 'lotus/loader'
require 'lotus/rendering_policy'
require 'lotus/middleware'

module Lotus
  # A full stack Lotus application
  #
  # @since 0.1.0
  #
  # @example
  #   require 'lotus'
  #
  #   module Bookshelf
  #     Application < Lotus::Application
  #     end
  #   end
  class Application
    include Lotus::Utils::ClassAttribute

    # Application configuration
    #
    # @since 0.1.0
    # @api private
    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure the application.
    # It yields the given block in the context of the configuration
    #
    # @param blk [Proc] the configuration block
    #
    # @since 0.1.0
    #
    # @see Lotus::Configuration
    #
    # @example
    #   require 'lotus'
    #
    #   module Bookshelf
    #     Application < Lotus::Application
    #       configure do
    #         # ...
    #       end
    #     end
    #   end
    def self.configure(&blk)
      configuration.configure(&blk)
    end

    # Return the routes for this application
    #
    # @return [Lotus::Router] a route set
    #
    # @since 0.1.0
    #
    # @see Lotus::Configuration#routes
    attr_reader :routes

    # Set the routes for this application
    #
    # @param [Lotus::Router]
    #
    # @since 0.1.0
    # @api private
    attr_writer :routes

    # Initialize and load a new instance of the application
    #
    # @return [Lotus::Application] a new instance of the application
    #
    # @since 0.1.0
    def initialize
      @loader = Lotus::Loader.new(self)
      @loader.load!

      @rendering_policy = RenderingPolicy.new(configuration)
    end

    # Return the configuration for this application
    #
    # @since 0.1.0
    # @api private
    #
    # @see Lotus::Application.configuration
    def configuration
      self.class.configuration
    end

    # Process a request.
    # This method makes Lotus applications compatible with the Rack protocol.
    #
    # @param env [Hash] a Rack env
    #
    # @return [Array] a serialized Rack response
    #
    # @since 0.1.0
    #
    # @see http://rack.github.io
    # @see Lotus::Application#middleware
    def call(env)
      middleware.call(env).tap do |response|
        @rendering_policy.render(response)
      end
    end

    # Rack middleware stack
    #
    # @return [Lotus::Middleware] the middleware stack
    #
    # @since 0.1.0
    # @api private
    #
    # @see Lotus::Middleware
    def middleware
      @middleware ||= Lotus::Middleware.new(self)
    end
  end
end
