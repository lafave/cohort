module PagesHelper
  # @param bucket [Hashie::Mash]
  # @param cohort_total [Integer] total number of users in the cohort across
  #   all interval buckets.
  #
  # @return [ActiveSupport::SafeBuffer]
  def formatted_interval_bucket(bucket, cohort_total)
    total_percentage      = number_to_percentage(bucket.total / cohort_total.to_f * 100, precision: 1)
    first_time_percentage = number_to_percentage(bucket.num_first_time_orderers / cohort_total.to_f * 100, precision: 1)

    content_tag :td, :class => "interval-bucket" do
      @content  = content_tag(:div, "#{total_percentage} orderers (#{bucket.total})")
      @content << content_tag(:div, "#{first_time_percentage} 1st time (#{bucket.num_first_time_orderers})")
    end
  end
end
