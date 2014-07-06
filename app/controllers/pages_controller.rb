class PagesController < ApplicationController

  def index
    @results = UserCohortQuery.execute index_params
  end

  private

  # @return [Hash]
  def index_params
    index_params = params.permit(:cohort_count).symbolize_keys

    if index_params[:cohort_count]
      index_params[:cohort_count] = Integer(index_params[:cohort_count])
    end

    index_params
  end
end