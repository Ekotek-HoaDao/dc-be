# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      private

      def render_success(data = nil, message = 'Success', status = :ok)
        response = { success: true, message: message }
        response[:data] = data if data.present?
        render json: response, status: status
      end

      def render_error(message = 'Error', status = :bad_request, errors = nil)
        response = { success: false, message: message }
        response[:errors] = errors if errors.present?
        render json: response, status: status
      end

      def render_paginated(collection, serializer = nil, meta = {})
        data = if serializer
                 collection.map { |item| serializer.new(item).as_json }
               else
                 collection
               end

        render json: {
          success: true,
          data: data,
          meta: {
            current_page: collection.current_page,
            per_page: collection.limit_value,
            total_pages: collection.total_pages,
            total_count: collection.total_count
          }.merge(meta)
        }
      end
    end
  end
end
