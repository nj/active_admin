module ActiveAdmin
  module Views

    # Wraps the content with optional pagination and available formats.
    #
    # *Example:*
    #
    #   collection_component collection, :entry_name => "Post" do
    #     div do
    #       h2 "Inside the
    #     end
    #   end
    #
    # It will also generate pagination links if pagination is enabled. If on
    # the other hand no pagination is required it can be disabled by using the
    # `:paginate => false` option:
    #
    #   collection_component collection, :entry_name => "Post", :paginate => false do
    #     ...
    #   end
    #
    # This will create a div with a sentence describing the number of
    # posts in one of the following formats:
    #
    # * "No Posts found"
    # * "Displaying 10 Posts" (if pagination is disabled)
    # * "Displaying all 10 Posts" (if pagination is enabled)
    # * "Displaying Posts 1 - 30 of 31 in total" (if pagination is enabled)
    #
    class Collection < ActiveAdmin::Component
      builder_method :collection_component

      attr_reader :collection

      # Builds a new collection component
      #
      # @param [Array] collection  A collection (if pagination is required, the collection must be
      #                            a "paginated" collection from kaminari)
      # @param [Hash]  options     These options will be passed on to the page_entries_info
      #                            method.
      #                            Useful keys:
      #                              :entry_name - The name to display for this resource collection
      #                              :param_name - Parameter name for page number in the links (:page by default)
      #                              :download_links - Set to false to skip download format links
      def build(collection, options = {})
        @collection = collection
        @options = options.reverse_merge!(:download_links => true, :paginate => true)

        unless collection.respond_to?(:num_pages)
          raise(StandardError, "Collection is not a paginated scope. Set collection.page(params[:page]).per(10) before calling :paginated_collection.")
        end
        
        div(page_entries_info.html_safe, :class => "collection_size_information")
        @contents = div(:class => "collection_contents")
        build_footer
        @built = true
      end

      # Override add_child to insert all children into the @contents div
      def add_child(*args, &block)
        if @built
          @contents.add_child(*args, &block)
        else
          super
        end
      end

      protected

      def build_footer
        div :id => "index_footer" do
          build_download_format_links if @options[:download_links]
          build_pagination            if @options[:paginate]
        end
      end

      def build_pagination
        options =  request.query_parameters.except(:commit, :format)
        options[:param_name] = @options[:param_name] if @options[:param_name]

        text_node paginate(collection, options.symbolize_keys)
      end

      # TODO: Refactor to new HTML DSL
      def build_download_format_links(formats = [:csv, :xml, :json])
        links = formats.collect do |format|
          link_to format.to_s.upcase, { :format => format}.merge(request.query_parameters.except(:commit, :format))
        end
        text_node [I18n.t('active_admin.download'), links].flatten.join("&nbsp;").html_safe
      end

      # modified from will_paginate
      def page_entries_info
        entry_name = @options[:entry_name] ||
          (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))

        if @options[:paginate]
          if collection.num_pages < 2
            case collection.size
            when 0; I18n.t('active_admin.pagination.empty', :model => entry_name.pluralize)
            when 1; I18n.t('active_admin.pagination.one', :model => entry_name)
            else;   I18n.t('active_admin.pagination.one_page', :model => entry_name.pluralize, :n => collection.size)
            end
          else
            offset = collection.current_page * active_admin_application.default_per_page
            total  = collection.total_count
            I18n.t('active_admin.pagination.multiple', :model => entry_name.pluralize, :from => (offset - active_admin_application.default_per_page + 1), :to => offset > total ? total : offset, :total => total)
          end
        else
          case collection.size
          when 0; I18n.t('active_admin.non_pagination.empty', :model => entry_name.pluralize)
          else;   I18n.t('active_admin.non_pagination.multiple', :model => entry_name.pluralize, :n => collection.size)
          end
        end
      end

    end
  end
end
