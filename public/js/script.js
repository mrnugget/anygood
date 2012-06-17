$(function () {
  $('#search_movie').submit(function(){
    var $form     = $(this);
    var movieName = $form.children('#movie_name_input').val();
    var movieYear = $form.children('#movie_year').val();

    var apiUrl    = $form.attr('action') + "/" + movieYear + "/" + movieName;

    $.get(apiUrl, function(movie){
      var movie_html = "";

      movie_html += "<h3>" + movie.name + " (" + movie.info.year + ")</h3>";
      movie_html += '<img src="' + movie.info.poster + '">';
      movie_html += "<h4>Combined Rating: " + movie.combined_rating + "</h4>";

      var movie_ratings = "<h4>Ratings: </h4>";

      $.each(movie.ratings, function(rating_site, rating) {
        movie_ratings += '<h4><a href="' + rating.url + '">';
        movie_ratings += rating_site + '</a>:</h4> ' + rating.score;
      });

      movie_html += movie_ratings;

      $('#result').html(movie_html);
    });
    return false;
  });

  $("#movie_name_input").autocomplete({
    source: function(request, response) {
      $.ajax({
        url: "/api/search",
        data: {
          term: request.term
        },
        success: function(data) {
          response($.map(data.movies, function(movie) {
            return {
              label: movie.name + " (" + movie.year + ")",
              value: movie.name,
              year: movie.year
            }
          }));
        },
      });
    },
    select: function(event,ui) {
      $('#movie_year').val(ui.item.year);
    },
    minLength: 2
  });
});
