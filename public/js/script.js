$(function () {
  $('#search_movie').submit(function(){
    var $form     = $(this);
    var movieName = $form.children('#movie_name_input').val();
    var movieYear = $form.children('#movie_year_input').val();

    var apiUrl    = $form.attr('action') + "/" + movieYear + "/" + movieName;

    $.get(apiUrl, function(movie){
      var movie_html = "";

      movie_html += "<h3>" + movie.name + "(" + movie.info.year + ")</h3>";
      movie_html += '<img src="' + movie.info.poster + '">';
      movie_html += "<h4>Combined Rating: " + movie.combined_rating + "</h4>";

      var movie_ratings = "<h4>Ratings: </h4>";
      $.each(movie.ratings, function(rating_site, rating) {
        movie_ratings += "<h4>" + rating_site + ":</h4>";
        $.each(rating, function(key, value) {
          movie_ratings += "<p>";
          movie_ratings += "<b>" + key + "</b>: " + value;
        });
      });
      movie_html += movie_ratings;

      $('#result').html(movie_html);
    });
    return false;
  });
});
