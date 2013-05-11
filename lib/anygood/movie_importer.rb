module AnyGood
  class MovieImporter
    def initialize(year)
      @uri = URI(URI.encode("http://en.wikipedia.org/wiki/#{year}_in_film"))
    end

    def fetch_movies
      response = Net::HTTP.get_response(@uri)
      parse_wiki_page(response.body)
    end

    private

      def parse_wiki_page(html)
        Nokogiri::HTML(html).css('table.wikitable td i a').map { |node|
          node.children.first.text
        }.uniq
      end
  end
end
