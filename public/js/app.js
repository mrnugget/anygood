_.templateSettings = { 
  interpolate : /\{\=(.+?)\}\}/g,
  evaluate: /\{\{(.+?)\}\}/g
};

var Movie = Backbone.Model.extend({
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

var MovieView = Backbone.View.extend({
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

var AnyGoodView = Backbone.View.extend({
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
    this.$loadingIndicator.show();

    var movie = new Movie({
      name: this.$nameInput.val(),
      year: this.$yearInput.val()
    });

    movie.fetch();

    this.renderMovie(movie);

    this.$loadingIndicator.hide();
  },

  renderMovie: function(movie) {
    movie.fetch();
    var view = new MovieView({model: movie});
    this.$("#result").html(view.render().el);
  },
});

var AnyGood = new AnyGoodView;
