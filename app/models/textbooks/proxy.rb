module Textbooks
  class Proxy < BaseProxy

    include ClassLogger
    include Proxies::Mockable
    include SafeJsonParser

    APP_ID = 'textbooks'

    def initialize(options = {})
      @section_numbers = options[:section_numbers]
      @dept = options[:dept]
      @slug = options[:slug]
      @course_catalog = format_course_catalog options[:course_catalog]
      @term = get_term @slug

      super(Settings.textbooks_proxy, options)
      initialize_mocks if @fake
    end

    def format_course_catalog(course_catalog)
      if Berkeley::Terms.fetch.campus[@slug].legacy?
        course_catalog
      else
        # For Campus Solutions terms, course catalogs must be zero-padded to at least three characters.
        course_catalog.rjust(3, '0')
      end
    end

    def google_book(isbn)
      google_book_url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:' + isbn
      google_response = {}
      return google_response if @fake
      response = get_response(google_book_url).parsed_response

      if response['totalItems'] > 0
        item = response['items'][0]
        google_response = {
          link: item['volumeInfo']['infoLink'],
          image: item['volumeInfo']['imageLinks'] ? "https://encrypted.google.com/books/images/frontcover/#{item['id']}?fife=w170-rw" : nil
        }
      end

      google_response
    end

    def process_material(material, sections_with_books)
      begin
        isbn = Integer(material['ean'], 10).to_s
      rescue
        logger.error "Textbook feed for #{@slug} #{@dept} #{@course_catalog} #{@section_numbers.join ', '} includes invalid ISBN \"#{material['ean']}\"; skipping entry"
        return nil
      end
      google_info = google_book(isbn)

      amazon_url = 'http://www.amazon.com/gp/search?index=books&linkCode=qs&keywords='
      chegg_url = 'http://www.chegg.com/search/'
      oskicat_url = 'http://oskicat.berkeley.edu/search~S1/?searchtype=i&searcharg='

      {
        author: material['author'],
        image: google_info[:image],
        title: material['title'],
        isbn: isbn,
        # Links
        amazonLink: amazon_url + isbn,
        cheggLink: chegg_url + isbn,
        oskicatLink: oskicat_url + isbn,
        googlebookLink: google_info[:link],
        # Bookstore
        bookstoreInfo: sections_with_books
      }
    end

    def get_sections_with_books(response)
      sections = []
      response.each do |item|
        if item['materials']
          sections.push({
            section: item['section'],
            dept: item['department'],
            course: item['course'],
            term: item['term'],
          })
        end
      end
      sections
    end

    def process_response(response)
      books = []

      sections_with_books = get_sections_with_books(response)

      response.each do |item|
        next unless item['materials']
        item['materials'].each do |material|
          if (processed_material = process_material(material, sections_with_books))
            books << processed_material
          end
        end
      end

      books
    end

    def get_term(slug)
      slug.sub('-', ' ').upcase
    end

    def get_as_json
      self.class.smart_fetch_from_cache(
        {id: "#{@slug}-#{@dept}-#{@course_catalog}-#{@section_numbers.join('-')}",
         user_message_on_exception: "Currently, we can't reach the bookstore. Check again later for updates, or contact the <a href=\"https://calstudentstore.berkeley.edu/textbook\" target=\"_blank\">ASUC book store</a>.",
         jsonify: true}) do
        get
      end
    end

    def get
      return {} unless Settings.features.textbooks

      response = request_bookstore_list(@section_numbers)
      books = process_response(response)
      book_unavailable_error = 'Currently, there is no textbook information for this course. Check again later for updates, or contact the <a href="https://calstudentstore.berkeley.edu/textbook" target="_blank">ASUC book store</a>.'

      {
        books: {
          items: books,
          bookUnavailableError: book_unavailable_error
        }
      }
    end

    def bookstore_link(section_numbers)
      params = []

      section_numbers.each do |section_number|
        params.push(
          {
            dept: @dept,
            course: @course_catalog,
            section: section_number,
            term: @term
          }
        )
      end
      uri_params = URI.encode(params.to_json)
      "#{Settings.textbooks_proxy.base_url}/course-info?courses=#{uri_params}"
    end

    def request_bookstore_list(section_numbers)
      url = bookstore_link(section_numbers)
      logger.info "Fake = #{@fake}; Making request to #{url}; cache expiration #{self.class.expires_in}"
      response = get_response(url,
        headers: {
          "Authorization" => "Token token=#{Settings.textbooks_proxy.token}"
        },
        ssl_version: 'TLSv1_2'
      )
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"
      response.parsed_response
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'textbooks.json')
    end

  end
end
