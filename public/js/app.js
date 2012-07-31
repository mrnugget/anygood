_.templateSettings = {
  interpolate: /\{\{\=(.+?)\}\}/g,
  evaluate: /\{\{(.+?)\}\}/g
};

var AnyGood = {};

AnyGood.Router = Backbone.Router.extend({
  routes: {
    "movies/:year/:name" : "showMovie",
    "search/:term" : "searchMovie"
  },
  showMovie: function(year, name) {
    AnyGood.mainView.getAndDisplayMovie(name.split('_').join(' '), year);
  },
  searchMovie: function(term) {
    AnyGood.mainView.getAndDisplaySearchResult(term);
  }
});

AnyGood.Movie = Backbone.Model.extend({
  defaults: {
    name: '',
    year: 0,
    info: '',
    ratings: [],
    combined_rating: 0
  },
  url: function () {
    return '/api/movies/' + this.get('year') + '/' + this.get('name');
  },
  getScoresToCalculate: function() {
    var scoresToCalculate = [];
    var ratings           = this.get('ratings');

    for (var i = 0; i < ratings.length; i++) {
      if (ratings[i].ignored === false || ratings[i].ignored === undefined) {
        if (ratings[i].score !== 0.0) {
          scoresToCalculate.push(ratings[i].score);
        }
      }
    }
    return scoresToCalculate;
  },

  calculateCombinedRating: function() {
    var scores         = this.getScoresToCalculate();
    var scoresSum      = 0;
    var combinedRating = 0;

    for (var i = 0; i < scores.length; i++) {
      scoresSum += scores[i];
    }
    if (scores.length > 0) {
      combinedRating = scoresSum / scores.length;
    }
    this.set('combined_rating', combinedRating);
    this.trigger('change');
  },

  toggleRatingIgnoreStatus: function(ratingIndex) {
    var ratings = this.get('ratings');

    if (ratings[ratingIndex] && ratings[ratingIndex].ignored === true) {
      ratings[ratingIndex].ignored = false;
    } else {
      ratings[ratingIndex].ignored = true;
    }
    this.set('ratings', ratings);
    this.calculateCombinedRating();
  }
});

AnyGood.SearchResult = Backbone.Model.extend({
  defaults: {
    movies: []
  }
});

AnyGood.AddMovieView = Backbone.View.extend({
  template: _.template($('#add-movie-template').html()),

  events: {
    'submit #add-movie': 'addMovie',
  },

  initialize: function() {
    _.bindAll(this, 'render', 'addMovie');
  },

  render: function() {
    this.$el.html(this.template());
    return this;
  },

  addMovie: function(event) {
    event.preventDefault();
    var movieName = this.$('#new-movie-name').val();
    var movieYear = this.$('#new-movie-year').val();

    if (movieName === '' || movieYear === '') {
      this.$('.not-valid').show();
    } else {
      this.makeRequest(this.capitalizeFirstLetters(movieName), movieYear);
    }
  },

  capitalizeFirstLetters: function(movieName) {
    var _words            = movieName.split(' ');
    var _transformedWords = [];
    for (var i = 0; i < _words.length; i++) {
      _transformedWords.push(_words[i].charAt(0).toUpperCase() + _words[i].slice(1));
    }
    return _transformedWords.join(' ');
  },

  makeRequest: function(movieName, movieYear) {
    $.ajax({
      url: '/api/search',
      type: 'POST',
      data: {
        movie: {name: movieName, year: movieYear}
      },
      success: function(data) {
        AnyGood.mainView.renderAddMovieSuccessView(movieName, movieYear);
      },
    });
  }
});

AnyGood.AddMovieSuccessView = Backbone.View.extend({
  template: _.template($('#add-movie-success-template').html()),

  initialize: function() {
    _.bindAll(this, 'render');
  },

  render: function() {
    this.$el.html(this.template(this.model));
    return this;
  }
});

AnyGood.NoSearchResultView = Backbone.View.extend({
  template: _.template($('#no-search-result-template').html()),

  initialize: function() {
    _.bindAll(this, 'render');
  },

  render: function() {
    this.$el.html(this.template());
    this.addMovieView = new AnyGood.AddMovieView({ el: this.$('.add-to-index-form') });
    this.addMovieView.render();
    return this;
  },
});

AnyGood.SearchResultView = Backbone.View.extend({
  template: _.template($('#search-result-template').html()),

  initialize: function() {
    _.bindAll(this, 'render');
    this.model.on('change', this.render);
  },

  render: function() {
    this.$el.html(this.template(this.model.toJSON()));
    this.addMovieView = new AnyGood.AddMovieView({ el: this.$('.add-to-index-form') });
    this.addMovieView.render();
    return this;
  },
});

AnyGood.LoadingMovieView = Backbone.View.extend({
  template: _.template($('#loading-template').html()),

  render: function() {
    this.$el.html(this.template(this.model.toJSON()));
    return this;
  },
});

AnyGood.MovieView = Backbone.View.extend({
  template: _.template($('#movie-template').html()),

  events: {
    'click .ignore-button': 'toggleRatingIgnore'
  },

  initialize: function() {
    _.bindAll(this, 'render');
    this.model.on('change', this.render);
  },

  render: function() {
    this.$el.html(this.template(this.model.toJSON()));
    return this;
  },

  toggleRatingIgnore: function(event) {
    event.preventDefault();

    var $button     = $(event.target);
    var $rating     = $button.parents('.rating');
    var ratingIndex = $rating.attr('data-rating-index');

    this.model.toggleRatingIgnoreStatus(ratingIndex);
  }
});

AnyGood.MainView = Backbone.View.extend({
  el: $('#anygood'),

  events: {
    'submit #search_movie': 'searchMovie',
  },

  initialize: function() {
    this.$form             = this.$('#search_movie');
    this.$nameInput        = this.$form.children('#movie-name-input');
    this.$yearInput        = this.$form.children('#movie-year-input');
  },

  searchMovie: function(event) {
    event.preventDefault();
    if (this.$yearInput.val() != '') {
      var url = "movies/" + this.$yearInput.val() + "/" + this.$nameInput.val().split(' ').join('_');
      this.$yearInput.val('');
      this.$nameInput.val('');
    } else {
      var url = "search/" + this.$nameInput.val();
    }
    AnyGood.router.navigate(url, {trigger: true});
  },

  getAndDisplaySearchResult: function(term) {
    $.ajax({
      url: '/api/search',
      data: {
        term: term
      },
      success: function(data) {
        if (data.movies.length > 0) {
          var searchResult = new AnyGood.SearchResult({movies: data.movies});
          var view         = new AnyGood.SearchResultView({model: searchResult});
        } else {
          var view = new AnyGood.NoSearchResultView({});
        }
        $("#content").html(view.render().el);
      },
    });
  },

  getAndDisplayMovie: function(name, year) {
    this.renderLoadingMovieView();
    var movie = new AnyGood.Movie({name: name, year: year});
    movie.fetch({
      success: function(movie) {
        AnyGood.mainView.renderMovie(movie);
      },
      error: function() {
        AnyGood.mainView.renderError();
      }
    });
  },

  renderMovie: function(movie) {
    var view = new AnyGood.MovieView({model: movie});
    this.$("#content").html(view.render().el);
  },

  renderError: function() {
    var template = _.template($('#500-template').html());
    this.$("#content").html(template());
  },

  renderLoadingMovieView: function() {
    var template = _.template($('#loading-template').html());
    this.$("#content").html(template());
  },

  renderAddMovieSuccessView: function(movieName, movieYear) {
    var view = new AnyGood.AddMovieSuccessView({model: { name: movieName, year: movieYear}});
    this.$("#content").html(view.render().el);
  }
});

$(function(AnyGood) {
  AnyGood.router   = new AnyGood.Router();
  AnyGood.mainView = new AnyGood.MainView;

  AnyGood.mainView.$nameInput.autocomplete({
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
      $('#movie-year-input').val(ui.item.year);
      $('#movie-name-input').val(ui.item.value);
      $(this).parents('form').submit();
      $(this).blur();
    },
    minLength: 2
  }).focus(function() {
    $(this).val('');
  });

  Backbone.history.start()
}(AnyGood));
