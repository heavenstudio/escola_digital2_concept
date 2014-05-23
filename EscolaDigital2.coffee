@Articles = new Meteor.Collection('articles')
@disciplines = ["CH – Filosofia","CH – Geografia","CH – História","CH – Sociologia","CN – Biologia","CN – Ciências","CN – Física","CN – Química","LC – Arte","LC – Educação Física","LC – Espanhol","LC – Inglês","LC – Português","MAT – Matemática"]
@years = ["Educação de Jovens e Adultos","Educação Especial","1º ano EF","2º ano EF","3º ano EF","4º ano EF","5º ano EF","6º ano EF","7º ano EF","8º ano EF","9º ano EF","1ª série EM","2ª série EM","3ª série EM","Educação Infantil"]

if Meteor.isClient
  handle = Meteor.subscribeWithPagination "articles", 10

  Template.results.articles = -> Articles.find()

  Template.filters.disciplines = -> disciplines

  Template.filters.years = -> years

  Template.filters.odd = -> this.index % 2 == 0
  Template.filters.even = -> this.index % 2 == 1

  show_or_hide_info = (e) ->
    article = $(e.target).closest('article')      
    article.find('.extra-info, h3').toggle()
    article.find('.more_info').toggle()
    article.find('.less_info').toggle()

  Template.results.events = {
    'click .more_info, click .less_info': show_or_hide_info
  }

  $(window).scroll ->
    atBottom = $(window).scrollTop() >= $(document).height() - $(window).height() - 40
    if atBottom && handle.ready()
      handle.loadNextPage()

if Meteor.isServer
  Meteor.publish "articles", (limit) -> Articles.find({}, {limit: limit})
