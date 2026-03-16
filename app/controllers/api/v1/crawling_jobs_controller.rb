# frozen_string_literal: true

module Api
  module V1
    class CrawlingJobsController < BaseController
      before_action :find_crawling_job, only: [:show, :update, :destroy, :start, :pause, :resume, :stop]

      def index
        jobs = current_user.crawling_jobs.includes(:crawled_data).page(pagination_params[:page])
                          .per(pagination_params[:per_page])
        
        render_paginated(jobs, CrawlingJobSerializer)
      end

      def show
        render_success(CrawlingJobSerializer.new(@crawling_job).as_json)
      end

      def create
        job = current_user.crawling_jobs.build(crawling_job_params)
        
        if job.save
          render_success(CrawlingJobSerializer.new(job).as_json, 'Crawling job created successfully', :created)
        else
          render_error('Failed to create crawling job', :unprocessable_entity, job.errors.full_messages)
        end
      end

      def update
        if @crawling_job.update(crawling_job_params)
          render_success(CrawlingJobSerializer.new(@crawling_job).as_json, 'Crawling job updated successfully')
        else
          render_error('Failed to update crawling job', :unprocessable_entity, @crawling_job.errors.full_messages)
        end
      end

      def destroy
        if @crawling_job.destroy
          render_success(nil, 'Crawling job deleted successfully')
        else
          render_error('Failed to delete crawling job')
        end
      end

      def start
        if @crawling_job.can_start?
          CrawlingWorker.perform_async(@crawling_job.id)
          @crawling_job.update(status: 'running', started_at: Time.current)
          render_success(nil, 'Crawling job started')
        else
          render_error("Cannot start job in #{@crawling_job.status} status")
        end
      end

      def pause
        if @crawling_job.running?
          @crawling_job.update(status: 'paused')
          render_success(nil, 'Crawling job paused')
        else
          render_error("Cannot pause job in #{@crawling_job.status} status")
        end
      end

      def resume
        if @crawling_job.paused?
          CrawlingWorker.perform_async(@crawling_job.id)
          @crawling_job.update(status: 'running')
          render_success(nil, 'Crawling job resumed')
        else
          render_error("Cannot resume job in #{@crawling_job.status} status")
        end
      end

      def stop
        if @crawling_job.running? || @crawling_job.paused?
          @crawling_job.update(status: 'stopped', finished_at: Time.current)
          render_success(nil, 'Crawling job stopped')
        else
          render_error("Cannot stop job in #{@crawling_job.status} status")
        end
      end

      private

      def find_crawling_job
        @crawling_job = current_user.crawling_jobs.find(params[:id])
      end

      def crawling_job_params
        params.require(:crawling_job).permit(
          :name, :url, :description, :crawling_rules, :schedule_type, 
          :schedule_value, :max_pages, :request_delay, :enabled
        )
      end
    end
  end
end
