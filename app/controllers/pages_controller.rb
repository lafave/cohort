class PagesController < ApplicationController

  def index
    @results = UserCohortQuery.execute
  end
end