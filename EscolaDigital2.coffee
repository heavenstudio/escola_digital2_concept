@Articles = new Meteor.Collection('articles')
@disciplines = ["CH - Filosofia","CH - Geografia","CH - História","CH - Sociologia","CN - Biologia","CN - Ciências","CN - Física","CN - Química","LC - Arte","LC - Educação Física","LC - Espanhol","LC - Inglês","LC - Português","MAT - Matemática"]
@years = ["Educação de Jovens e Adultos","Educação Especial","1º ano EF","2º ano EF","3º ano EF","4º ano EF","5º ano EF","6º ano EF","7º ano EF","8º ano EF","9º ano EF","1ª série EM","2ª série EM","3ª série EM","Educação Infantil"]
@medias = ['Animação', 'Aplicativo Móvel','Apresentação Multimídia','Áudio','Aula Digital','Infográfico','Jogo','Livro Digital','Mapa','Simulador','Software','Vídeo']

if Meteor.isClient
  Session.setDefault('years', years)
  Session.setDefault('disciplines', disciplines)
  Session.setDefault('medias', medias)
  Session.setDefault('limit', 10)

  loadContentIfEnded = ->
    atBottom = $(window).scrollTop() >= $(document).height() - $(window).height() - 40
    Session.set('limit', Session.get('limit')+10) if atBottom

  Meteor.startup ->
    Session.set('years', years)
    Session.set('disciplines', disciplines)
    Session.set('medias', medias)
    Session.set('limit', 10)

  handle = Meteor.subscribe "articles"

  Template.filters.disciplines = -> disciplines
  Template.filters.years = -> years
  Template.filters.medias = -> medias
  Template.filters.isDisciplineChecked = -> Session.get('disciplines').indexOf(this)
  Template.filters.isYearChecked = -> Session.get('years').indexOf(this)
  Template.filters.isMediaChecked = -> Session.get('medias').indexOf(this)

  Template.results.articles = ->
    query = {disciplines: {$in: Session.get('disciplines')}, years: {$in: Session.get('years')}, media: {$in: Session.get('medias')}}
    Session.set('articles_found', Articles.find(query).count())
    Articles.find(query, {limit: Session.get('limit')})
  Template.results.articles_count = -> Session.get('articles_found')

  show_or_hide_info = (e) ->
    article = $(e.target).closest('article')      
    article.find('.extra-info, h3').toggle()
    article.find('.more_info').toggle()
    article.find('.less_info').toggle()

  Template.results.events = {
    'click .more_info, click .less_info': show_or_hide_info
  }

  Template.filters.events = {
    'change [name=disciplines]': (e) ->
      value = $(e.target).closest('label').find('.text').text()
      currentDisciplines = Session.get('disciplines')
      if $(e.target).prop('checked')
        currentDisciplines.push(value)
        Session.set('disciplines', currentDisciplines)
        Session.set('limit',10)
      else
        Session.set('disciplines', currentDisciplines.filter (e) -> e != value)
        Session.set('limit',10)
      loadContentIfEnded()

    'change [name=years]': (e) ->
      value = $(e.target).closest('label').find('.text').text()
      currentYears = Session.get('years')
      if $(e.target).prop('checked')
        currentYears.push(value)
        Session.set('years', currentYears)
        Session.set('limit',10)
      else
        Session.set('years', currentYears.filter (e) -> e != value)
        Session.set('limit',10)
      loadContentIfEnded()

    'change [name=medias]': (e) ->
      value = $(e.target).closest('label').find('.text').text()
      currentMedias = Session.get('medias')
      if $(e.target).prop('checked')
        currentMedias.push(value)
        Session.set('medias', currentMedias)
        Session.set('limit',10)
      else
        Session.set('medias', currentMedias.filter (e) -> e != value)
        Session.set('limit',10)
      loadContentIfEnded()
  }

  $(window).scroll(loadContentIfEnded)

if Meteor.isServer
  Meteor.publish "articles", -> Articles.find({})
