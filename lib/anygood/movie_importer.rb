module AnyGood
  class MovieImporter
    def initialize(year)
      @uri = wiki_url(year)
    end

    def fetch_movies
      response    = Net::HTTP.get_response(@uri)
      @movie_list = parse_wiki_page(response.body)
    end

    private

      def wiki_url(year)
        URI(URI.encode("http://en.wikipedia.org/wiki/#{year}_in_film"))
      end

      def parse_wiki_page(html)
        names = []
        doc   = Nokogiri::HTML(html)

        doc.css('table.wikitable td i a').each do |node|
          names << node.children.first.text
        end

        names.uniq
      end
  end
end
