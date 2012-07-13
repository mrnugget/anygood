_.templateSettings = {
  interpolate : /\{\{\=(.+?)\}\}/g,
  evaluate: /\{\{(.+?)\}\}/g
};

var AnyGood = {};

AnyGood.Router = Backbone.Router.extend({
  routes: {
    "movies/:year/:name" : "showMovie",
  },
  showMovie: function(year, name) {
    var movieName = name.split('_').join(' ');
    AnyGood.mainView.getAndDisplayMovie(movieName, year, AnyGood.mainView.$loadingIndicator);
  }
});

AnyGood.Movie = Backbone.Model.extend({
  defaults: {
    name: '',
    year: 0,
    info: '',
    ratings: {},
    combined_rating: 0
  },
  url: function () {
    return '/api/movies/' + this.get('year') + '/' + this.get('name');
  }
});

AnyGood.MovieView = Backbone.View.extend({
  template: _.template($('#movie-template').html()),

  initialize: function() {
    _.bindAll(this, 'render');
    this.model.on('change', this.render);
  },

  render: function() {
    this.$el.html(this.template(this.model.toJSON()));
    return this;
  }
});

AnyGood.MainView = Backbone.View.extend({
  el: $('#anygood'),

  events: {
    'submit #search_movie': 'searchMovie',
  },

  initialize: function() {
    this.$form             = this.$('#search_movie');
    this.$nameInput        = this.$form.children('#movie_name_input');
    this.$yearInput        = this.$form.children('#movie_year_input');
    this.$loadingIndicator = this.$('#loading');
  },

  searchMovie: function(event) {
    event.preventDefault();
    var url = "movies/" + this.$yearInput.val() + "/" + this.$nameInput.val().split(' ').join('_');
    AnyGood.router.navigate(url, {trigger: true});
  },

  getAndDisplayMovie: function(name, year, $spinner) {
    $spinner.show();

    var movie = new AnyGood.Movie({name: name, year: year});

    movie.fetch({
      success: function(movie) {
        AnyGood.mainView.renderMovie(movie);
        $spinner.hide();
      }
    });
  },

  renderMovie: function(movie) {
    var view = new AnyGood.MovieView({model: movie});
    this.$("#result").html(view.render().el);
  },
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
      $('#movie_year_input').val(ui.item.year);
      $('#movie_name_input').val(ui.item.value);
      $(this).parents('form').submit();
    },
    minLength: 2
  });

  Backbone.history.start()
}(AnyGood));
