module CalendarHelper
  def calendar(date = Date.today,options={}, &block)
    Calendar.new(self, date,options, block).table
  end

  class Calendar < Struct.new(:view, :date,:options, :callback)
    HEADER = %w[Sun Mon Tues Wed Thu Fri Sat]
    START_DAY = :sunday

    delegate :content_tag, to: :view

    def table
      cal_table = content_tag :table, class: "calendar" do
        header + week_rows
      end
      [month_row,cal_table].join.html_safe
    end

    def month_row
      options.present? ? (content_tag :div, options[:prev_link] + content_tag(:div, "#{Date::MONTHNAMES[date.month].upcase} #{date.year}", class: "monthYear") + options[:next_link]).html_safe : ""
    end

    def header
      content_tag :tr do
        HEADER.map { |day| content_tag :th, day }.join.html_safe
      end
    end

    def week_rows
      weeks.map do |week|
        content_tag :tr do
          week.map { |day| day_cell(day) }.join.html_safe
        end
      end.join.html_safe
    end

    def day_cell(day)
      content_tag :td, (date.month==day.month ? view.capture(day, &callback) : ""), class: day_classes(day)
    end

    def day_classes(day)
      classes = []
      classes << "blackout" if options[:blackout_dates] && options[:blackout_dates].include?(day)
      classes << "today" if day == Date.today
      classes << "notmonth" if day.month != date.month
      classes.empty? ? nil : classes.join(" ")
    end

    def weeks
      first = date.beginning_of_month.beginning_of_week(START_DAY)
      last = date.end_of_month.end_of_week(START_DAY)
      (first..last).to_a.in_groups_of(7)
    end
  end
end