# frozen_string_literal: true

module Crawling
  class Parser
    def initialize(rules = {})
      @rules = rules.with_indifferent_access
    end

    def parse_html(html_content, url = nil)
      doc = Nokogiri::HTML(html_content)
      parsed_data = {}

      # Extract basic page information
      parsed_data[:title] = extract_title(doc)
      parsed_data[:meta_description] = extract_meta_description(doc)
      parsed_data[:meta_keywords] = extract_meta_keywords(doc)
      parsed_data[:links] = extract_links(doc, url)
      parsed_data[:images] = extract_images(doc, url)

      # Apply custom extraction rules
      if @rules.present?
        parsed_data[:custom] = apply_custom_rules(doc)
      end

      # Extract text content
      parsed_data[:text_content] = extract_text_content(doc)
      parsed_data[:word_count] = count_words(parsed_data[:text_content])

      parsed_data
    rescue Nokogiri::XML::SyntaxError => e
      Rails.logger.error("HTML parsing error: #{e.message}")
      { error: "Failed to parse HTML: #{e.message}" }
    end

    def parse_json(json_content)
      JSON.parse(json_content)
    rescue JSON::ParserError => e
      Rails.logger.error("JSON parsing error: #{e.message}")
      { error: "Failed to parse JSON: #{e.message}" }
    end

    def parse_xml(xml_content)
      doc = Nokogiri::XML(xml_content)
      xml_to_hash(doc.root)
    rescue Nokogiri::XML::SyntaxError => e
      Rails.logger.error("XML parsing error: #{e.message}")
      { error: "Failed to parse XML: #{e.message}" }
    end

    private

    attr_reader :rules

    def extract_title(doc)
      doc.at_css('title')&.text&.strip || ''
    end

    def extract_meta_description(doc)
      doc.at_css('meta[name="description"]')&.[]('content') || ''
    end

    def extract_meta_keywords(doc)
      doc.at_css('meta[name="keywords"]')&.[]('content') || ''
    end

    def extract_links(doc, base_url)
      links = []
      
      doc.css('a[href]').each do |link|
        href = link['href']
        next if href.blank?

        absolute_url = make_absolute_url(href, base_url)
        
        links << {
          text: link.text.strip,
          url: absolute_url,
          internal: internal_link?(absolute_url, base_url)
        }
      end

      links.uniq { |link| link[:url] }
    end

    def extract_images(doc, base_url)
      images = []
      
      doc.css('img[src]').each do |img|
        src = img['src']
        next if src.blank?

        absolute_url = make_absolute_url(src, base_url)
        
        images << {
          src: absolute_url,
          alt: img['alt'] || '',
          title: img['title'] || ''
        }
      end

      images.uniq { |img| img[:src] }
    end

    def extract_text_content(doc)
      # Remove script and style elements
      doc.css('script, style').remove
      
      # Get all text content
      doc.text.gsub(/\s+/, ' ').strip
    end

    def count_words(text)
      return 0 if text.blank?
      
      text.scan(/\w+/).size
    end

    def apply_custom_rules(doc)
      custom_data = {}

      rules.each do |key, rule|
        case rule[:type]
        when 'css_selector'
          custom_data[key] = extract_by_css_selector(doc, rule)
        when 'xpath'
          custom_data[key] = extract_by_xpath(doc, rule)
        when 'regex'
          custom_data[key] = extract_by_regex(doc.to_s, rule)
        end
      end

      custom_data
    end

    def extract_by_css_selector(doc, rule)
      elements = doc.css(rule[:selector])
      
      if rule[:multiple]
        elements.map { |el| extract_element_data(el, rule) }
      else
        extract_element_data(elements.first, rule) if elements.any?
      end
    end

    def extract_by_xpath(doc, rule)
      elements = doc.xpath(rule[:xpath])
      
      if rule[:multiple]
        elements.map { |el| extract_element_data(el, rule) }
      else
        extract_element_data(elements.first, rule) if elements.any?
      end
    end

    def extract_by_regex(content, rule)
      matches = content.scan(Regexp.new(rule[:pattern], rule[:flags] || 0))
      
      if rule[:multiple]
        matches.flatten
      else
        matches.first&.first
      end
    end

    def extract_element_data(element, rule)
      return nil unless element

      case rule[:extract]
      when 'text'
        element.text.strip
      when 'html'
        element.inner_html.strip
      when 'attribute'
        element[rule[:attribute]]
      else
        element.text.strip
      end
    end

    def make_absolute_url(url, base_url)
      return url if url.match?(/\Ahttps?:\/\//)
      return url if base_url.blank?

      URI.join(base_url, url).to_s
    rescue URI::InvalidURIError
      url
    end

    def internal_link?(url, base_url)
      return false if base_url.blank?
      
      base_host = URI.parse(base_url).host
      url_host = URI.parse(url).host
      
      base_host == url_host
    rescue URI::InvalidURIError
      false
    end

    def xml_to_hash(element)
      return element.text if element.children.empty?

      result = {}
      
      element.children.each do |child|
        next if child.text?

        key = child.name
        value = xml_to_hash(child)

        if result[key]
          result[key] = [result[key]] unless result[key].is_a?(Array)
          result[key] << value
        else
          result[key] = value
        end
      end

      result
    end
  end
end
