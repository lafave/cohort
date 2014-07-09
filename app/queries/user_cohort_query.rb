class UserCohortQuery
  # Convenience method to execute the query object.
  def self.execute(*args)
    new(*args).execute
  end

  # @param cohort_count [Integer] the number of user cohorts to fetch.
  #   Default: 8
  #
  # @note if cohort_count < 0 then it will be set to 0.
  #
  # @return [UserCohortQuery]
  def initialize(cohort_count: 8)
    @cohort_count = cohort_count < 0 ? 0 : cohort_count
  end

  # @note cohorts can be accessed via the `cohorts` method.
  #
  # @return [Hashie::Mash]
  def execute
    results = Elasticsearch::Model.client.search \
      :body  => build_query,
      :index => [:orders, :users],
      :type  => [:order, :user]

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
        json.orders do
          json.filter do
            json.bool do
              json.set! :must, [
                { :term => { :_type => :order } }
              ]
            end
          end
          json.aggs do
            json.weekly do
              json.date_histogram do
                json.field :"user.created_at"
                json.format :"yyyy-MM-dd"
                json.interval :week
                json.min_doc_count 0
                json.time_zone -7
              end
              json.aggs do
                json.cohorts do
                  json.date_histogram do
                    json.field :created_at
                    json.interval :week
                    json.min_doc_count 0
                    json.time_zone -7
                  end
                  json.aggs do
                    json.user_count do
                      json.cardinality do
                        json.field :"user.created_at"
                        json.precision_threshold 1000
                      end
                    end
                    json.first_time_orderers do
                      json.filter do
                        json.bool do
                          json.set! :must, [
                            { :term => { :order_num => 1 } }
                          ]
                        end
                      end
                      json.aggs do
                        json.user_count do
                          json.cardinality do
                            json.field :"user.created_at"
                            json.precision_threshold 1000
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
        json.users do
          json.filter do
            json.bool do
              json.set! :must, [
                { :term => { :_type => :user } }
              ]
            end
          end
          json.aggs do
            json.weekly do
              json.date_histogram do
                json.field :"user.created_at"
                json.format :"yyyy-MM-dd"
                json.interval :week
                json.min_doc_count 0
                json.time_zone -7
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
    cohorts = format_cohorts(results["aggregations"])
      .reverse
      .take(@cohort_count)

    {
      :cohorts              => cohorts,
      :max_interval_buckets => cohorts.last.try(:[], :interval_buckets).try(:size) || 0
    }
  end

  # @param cohorts [Array<Hash>] an array of hashes containing cohort data.
  #
  # @return [Hash]
  def format_cohorts(cohorts)
    time_format = "%-m/%-e"

    cohorts["orders"]["weekly"]["buckets"].each_with_index.map do |cohort, i|
      week              = Time.parse(cohort["key_as_string"])
      beginning_of_week = week.beginning_of_week.strftime(time_format)
      end_of_week       = week.end_of_week.strftime(time_format)

      {
        :interval_buckets => format_interval_buckets(cohort["cohorts"]["buckets"]),
        :title            => "#{beginning_of_week}-#{end_of_week}",
        :total            => cohorts["users"]["weekly"]["buckets"][i].try(:[], "doc_count")
      }
    end
  end

  # @param order_buckets [Array<Hash>] an array of hashes containing bucketed
  #   order data.
  #
  # @return [Hash]
  def format_interval_buckets(order_buckets)
    order_buckets.each_with_index.map do |bucket, i|
      {
        :num_first_time_orderers => bucket["first_time_orderers"]["user_count"]["value"],
        :title                   => "#{((i + 1) * 7) - 7}-#{(i + 1) * 7} days",
        :total                   => bucket["user_count"]["value"]
      }
    end
  end
end