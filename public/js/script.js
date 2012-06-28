$(function () {
  $('#search_movie').submit(function(){
    function generateHtmlFromMovie(movie) {
      var movieHtml = '';

      movieHtml += '<h3>' + movie.name + ' (' + movie.info.year + ')</h3>';
      movieHtml += '<img src="' + movie.info.poster + '">';
      movieHtml += '<h4>Combined Rating: ' + movie.combined_rating + '</h4>';

      var movieRatings = '<h4>Ratings: </h4>';
      $.each(movie.ratings, function(rating_site, rating) {
        if (rating.error) {
          movieRatings += '<h4>' + rating_site + '</h4>';
          movieRatings += rating.error;
        } else {
          movieRatings += '<h4><a href="' + rating.url + '">';
          movieRatings += rating_site + '</a>:</h4> ' + rating.score;
        }
      });
      movieHtml += movieRatings;
      return movieHtml;
    }

    var $form     = $(this);
    var movieName = $form.children('#movie_name_input').val();
    var movieYear = $form.children('#movie_year_input').val();
    var apiUrl    = $form.attr('action') + '/' + movieYear + '/' + movieName;

    $.ajax({
      url: apiUrl,
      beforeSend: function() {
        $('#loading').show();
      },
      success: function(movie){
        var movieHtml = generateHtmlFromMovie(movie);
        $('#result').html(movieHtml);
        $('#loading').hide();
      }
    });
    return false;
  });

  $('#movie_name_input').autocomplete({
    source: function(request, response) {
      $.ajax({
        url: '/api/search',
        data: {
          term: request.term
        },
        success: function(data) {
          response($.map(data.movies, function(movie) {
            return {
              label: movie.name + ' (' + movie.year + ')',
              value: movie.name,
              year: movie.year
            }
          }));
        },
      });
    },
    select: function(event,ui) {
      $('#movie_year_input').val(ui.item.year);
      $('#movie_name_input').val(ui.item.value);
      $(this).parents('form').submit();
    },
    minLength: 2
  });
});
