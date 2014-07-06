class PagesController < ApplicationController

  def index
    @results = UserCohortQuery.execute index_params
  end

  private

  # @return [Hash]
  def index_params
    index_params = params.permit(:cohort_count).symbolize_keys

    if index_params[:cohort_count]
      index_params[:cohort_count] = int_param(:cohort_count, 0)
    end

    index_params
  end

  # @param name [String, Symbol] the name of the param to coerce to an Integer.
  # @param default [Integer, NilClass] a default value to return if there is an
  #   error parsing the param.
  #
  # @return []
  def int_param(name, default = nil)
    Integer(params[name])
  rescue ArgumentError, TypeError
    default
  end
end