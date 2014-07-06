require "jbuilder"

class UserCohortQuery
  # Convenience method to execute the query object.
  def self.execute(*args)
    new(*args).execute
  end

  # @param cohort_count [Integer] the number of user cohorts to fetch.
  #   Default: 8
  #
  # @return [UserCohortQuery]
  def initialize(cohort_count: 8)
    @cohort_count = cohort_count
  end

  # @note cohorts can be accessed via the `cohorts` method.
  #
  # @return [Hashie::Mash]
  def execute
    results = Order.__elasticsearch__.client.search \
      :body  => build_query,
      :index => :orders,
      :type  => :order

    Hashie::Mash.new(format_results(results))
  end

  private

  # @return [String]
  def build_query
    Jbuilder.encode do |json|
      # Query
      json.query do
        json.match_all {}
      end
      # Aggregations
      json.aggs do
        json.weekly do
          json.date_histogram do
            json.field :"user.created_at"
            json.format :"yyyy-MM-dd"
            json.interval :week
            json.min_doc_count 0
            json.time_zone -8
          end
          json.aggs do
            json.orders do
              json.date_histogram do
                json.field :created_at
                json.format :"MM/dd"
                json.interval :week
                json.min_doc_count 0
                json.time_zone -8
              end
              json.aggs do
                json.first_time_orders do
                  json.filter do
                    json.bool do
                      json.set! :must, [
                        { :term => { :order_num => 1 } }
                      ]
                    end
                  end
                end
              end
            end
          end
        end
      end
      # Limit
      json.size 0
    end
  end

  # @param results [Hash] results from elasticsearch which need to be
  #   transformed into an easier-to-consume format.
  #
  # @return [Hash]
  def format_results(results)
    cohorts = format_cohorts(results["aggregations"]["weekly"]["buckets"])
      .reverse
      .take(@cohort_count)

    {
      :cohorts             => cohorts,
      :max_order_intervals => cohorts.map { |c| c[:order_intervals].size }.max
    }
  end

  # @param cohorts [Array<Hash>] an array of hashes containing cohort data.
  #
  # @return [Hash]
  def format_cohorts(cohorts)
    time_format = "%-m/%-e"

    cohorts.map do |cohort|
      week              = Time.parse(cohort["key_as_string"])
      beginning_of_week = week.beginning_of_week.strftime(time_format)
      end_of_week       = week.end_of_week.strftime(time_format)

      {
        :order_intervals => format_order_buckets(cohort["orders"]["buckets"]),
        :title           => "#{beginning_of_week}-#{end_of_week}",
        :total           => cohort["doc_count"]
      }
    end
  end

  # @param order_buckets [Array<Hash>] an array of hashes containing bucketed
  #   order data.
  #
  # @return [Hash]
  def format_order_buckets(order_buckets)
    order_buckets.each_with_index.map do |bucket, i|
      {
        :first_time_orders => bucket["first_time_orders"]["doc_count"],
        :title             => "#{((i + 1) * 7) - 7}-#{(i + 1) * 7} days",
        :total             => bucket["doc_count"]
      }
    end
  end
end