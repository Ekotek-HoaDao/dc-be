# frozen_string_literal: true

module Api
  module V1
    class DataController < BaseController
      def index
        data = current_user.crawled_data.includes(:crawling_job)
                          .page(pagination_params[:page])
                          .per(pagination_params[:per_page])
        
        # Apply filters
        data = data.where(crawling_job_id: params[:crawling_job_id]) if params[:crawling_job_id].present?
        data = data.where('created_at >= ?', Date.parse(params[:from_date])) if params[:from_date].present?
        data = data.where('created_at <= ?', Date.parse(params[:to_date])) if params[:to_date].present?
        
        render_paginated(data, CrawledDataSerializer)
      end

      def show
        data = current_user.crawled_data.find(params[:id])
        render_success(CrawledDataSerializer.new(data).as_json)
      end

      def destroy
        data = current_user.crawled_data.find(params[:id])
        
        if data.destroy
          render_success(nil, 'Data deleted successfully')
        else
          render_error('Failed to delete data')
        end
      end
    end
  end
end
