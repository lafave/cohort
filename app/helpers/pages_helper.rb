module PagesHelper
  def formatted_order_interval(interval, cohort_total)
    total_percentage      = number_to_percentage(interval.total / cohort_total.to_f * 100, precision: 1)
    first_time_percentage = number_to_percentage(interval.first_time_orders / cohort_total.to_f * 100, precision: 1)

    content_tag :td, :class => "order-interval" do
      @content  = content_tag(:div, "#{total_percentage} orderers (#{interval.total})")
      @content << content_tag(:div, "#{first_time_percentage} 1st time (#{interval.first_time_orders})")
    end
  end
end
