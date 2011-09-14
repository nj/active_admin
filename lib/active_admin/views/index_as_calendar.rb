module ActiveAdmin
  module Views

     # = Index as a Calendar
     #
     # Sometimes you want to display the index screen for a set of resources as a
     # calendar. To do so, use the :calendar option for the index block.
     #
     #     index :as => :calendar
     #
     # By default resources will be groups by their `updated_at` attribute. But if
     # you need to, you can specify another attribute to group by using the :group_by
     # argument:
     #
     #     index :as => :calendar, :group_by => :published_at
     #
     class IndexAsCalendar < ActiveAdmin::Component

      def build(page_config, collection)
        @page_config = page_config
        @collection = collection
        build_calendar
      end

      def group_by
        @page_config[:group_by] || default_group_by
      end

      protected

      def build_calendar
        build_navigation
        build_table
      end

      def build_navigation
        h2 current_month.strftime("%B %Y")

        prev_month = current_month.at_beginning_of_month - 1
        next_month = current_month.at_end_of_month + 1
        ul :id => 'index_calendar_nav' do
          li link_to("Today"),                                                          :class => 'today'
          li link_to("Previous", :year => prev_month.year, :month => prev_month.month), :class => 'prev'
          li link_to("Next",     :year => next_month.year, :month => next_month.month), :class => 'next'
        end
      end

      def build_table
        table :id => "index_calendar" do
          build_table_headers
          build_table_body
        end
      end

      def build_table_headers
        thead do
          tr do
            7.times do |i|
              # TODO: Figure out if we need to take of weeks that start with anything other than monday
              th I18n.t('date.abbr_day_names').rotate[i].capitalize, :abbr => I18n.t('date.day_names').rotate[i].capitalize
            end
          end
        end
      end

      def build_table_body
        tbody do
          start_date = current_month.at_beginning_of_month.beginning_of_week
          end_date   = current_month.at_end_of_month.end_of_week
          (start_date..end_date).to_a.in_groups_of(7).map do |week|
            build_week week.first..week.last
          end
        end
      end

      def build_week(date_range)
        tr do
          date_range.map do |date|
            build_day(date)
          end
        end
      end

      def build_day(date)
        active_month = date.month == current_month.month
        active_year  = date.year  == current_month.year

        day_classes = [(active_month && active_year ? 'current_month' : 'not_current_month')]
        day_classes << 'today' if date == Time.zone.now.to_date

        td :class => day_classes.join(' ') do
          div :class => 'day' do
            date.day == 1 ? date.strftime("%b #{date.day}") : date.day.to_s
          end
          instance_exec(date, collection.where(:send_at => date), &@page_config.block)
        end
      end

      def current_month
        @current_month ||= begin
          # TODO: Add params validation
          params[:year]  ||= Time.zone.now.year
          params[:month] ||= Time.zone.now.month
          Time.zone.parse("#{params[:year]}-#{params[:month]}-1").to_date
        end
      end

      def default_group_by
        :updated_at
      end

    end
  end
end
