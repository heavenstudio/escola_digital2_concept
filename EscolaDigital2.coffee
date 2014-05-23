@Articles = new Meteor.Collection('articles')

if Meteor.isClient
  handle = Meteor.subscribeWithPagination "articles", 10

  Template.results.articles = -> Articles.find()

  Template.filters.disciplines = -> ["CH – Filosofia","CH – Geografia","CH – História","CH – Sociologia","CN – Biologia","CN – Ciências","CN – Física","CN – Química","LC – Arte","LC – Educação Física","LC – Espanhol","LC – Inglês","LC – Português","MAT – Matemática"]

  Template.filters.years = -> ["Educação de Jovens e Adultos","Educação Especial","1º ano EF","2º ano EF","3º ano EF","4º ano EF","5º ano EF","6º ano EF","7º ano EF","8º ano EF","9º ano EF","1ª série EM","2ª série EM","3ª série EM","Educação Infantil"]

  Template.filters.odd = -> this.index % 2 == 0
  Template.filters.even = -> this.index % 2 == 1

  $(window).scroll ->
    atBottom = $(window).scrollTop() >= $(document).height() - $(window).height() - 40
    if atBottom && handle.ready()
      handle.loadNextPage()

if Meteor.isServer
  Meteor.publish "articles", (limit) -> Articles.find({}, {limit: limit})
