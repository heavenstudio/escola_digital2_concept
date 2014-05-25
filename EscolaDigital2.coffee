@Articles = new Meteor.Collection('articles')
@disciplines = ["CH - Filosofia","CH - Geografia","CH - História","CH - Sociologia","CN - Biologia","CN - Ciências","CN - Física","CN - Química","LC - Arte","LC - Educação Física","LC - Espanhol","LC - Inglês","LC - Português","MAT - Matemática"]
@years = ["Educação de Jovens e Adultos","Educação Especial","1º ano EF","2º ano EF","3º ano EF","4º ano EF","5º ano EF","6º ano EF","7º ano EF","8º ano EF","9º ano EF","1ª série EM","2ª série EM","3ª série EM","Educação Infantil"]
@medias = ['Animação', 'Aplicativo Móvel','Apresentação Multimídia','Áudio','Aula Digital','Infográfico','Jogo','Livro Digital','Mapa','Simulador','Software','Vídeo']

if Meteor.isClient
  resetResults = ->
    Session.set('limit',10)
    Meteor.call 'articles_found', Session.get('disciplines'), Session.get('years'), Session.get('medias'), Session.get('query'), (error, result) ->
      Session.set 'articles_found', result

  timer = 0
  delay = (ms, callback) ->
    clearTimeout timer
    timer = setTimeout(callback, ms)

  Meteor.startup ->
    Session.set('years', years)
    Session.set('disciplines', disciplines)
    Session.set('medias', medias)
    Session.set('query', '')
    Session.set('sort_field', 'rating')
    Session.set('sort_order', -1)
    resetResults()
  Session.setDefault('years', years)
  Session.setDefault('disciplines', disciplines)
  Session.setDefault('medias', medias)
  Session.setDefault('limit', 10)
  Session.setDefault('query', '')
  Session.setDefault('sort_field', 'rating')
  Session.setDefault('sort_order', -1)

  loadContentIfEnded = ->
    atBottom = $(window).scrollTop() >= $(document).height() - $(window).height() - 40
    Session.set('limit', Session.get('limit')+10) if atBottom

  Deps.autorun ->
    Meteor.subscribe "articles", Session.get('disciplines'), Session.get('years'), Session.get('medias'),
      Session.get('query'), Session.get('limit'), Session.get('sort_field'), Session.get('sort_order')

  Template.filters.disciplines = -> disciplines
  Template.filters.years = -> years
  Template.filters.medias = -> medias
  Template.filters.isDisciplineChecked = -> Session.get('disciplines').indexOf(this)
  Template.filters.isYearChecked = -> Session.get('years').indexOf(this)
  Template.filters.isMediaChecked = -> Session.get('medias').indexOf(this)

  Template.results.articles = ->
    options = {limit: Session.get('limit'), sort: {}}
    options.sort[Session.get('sort_field')] = parseInt(Session.get('sort_order'))
    Articles.find({}, options)
    
  Template.results.articles_count = -> Session.get('articles_found')
  Template.results.stars = -> [1..this.rating]
  Template.results.creation_date = ->
    date = new Date(this.created_at)
    "#{date.getDate()}/#{date.getMonth()+1}/#{date.getFullYear()} #{date.getHours()}:#{date.getMinutes()}"
  Template.results.missing_stars = ->
    return [] if this.rating == 5
    [1..(5-this.rating)]

  show_or_hide_info = (e) ->
    article = $(e.target).closest('article')      
    article.find('.extra-info').slideToggle()
    article.find('.more_info').toggle()
    article.find('.less_info').toggle()
    e.preventDefault()

  Template.results.events = {
    'click .more_info, click .less_info': show_or_hide_info,
    'change [name=sort_field]': (e) ->
      Session.set('sort_field', e.currentTarget.value)
      Session.set('sort_order', $(e.target).find(':selected').data('order'))
      resetResults()
  }

  Template.head.events = {
    'keyup #q': (e) ->
      recent_changed = true
      query = e.currentTarget.value
      delay 500, ->
        if query.length >= 3
          Session.set('query', query)
        else
          Session.set('query', '')
        resetResults()
  }

  Template.filters.events = {
    'click .all-disciplines': (e) ->
      Session.set('disciplines', disciplines)
      $("[name=disciplines]").prop('checked', true)
      resetResults()

    'click .no-disciplines': (e) ->
      Session.set('disciplines', [])
      $("[name=disciplines]").prop('checked', false)
      resetResults()

    'click .all-years': (e) ->
      Session.set('years', years)
      $("[name=years]").prop('checked', true)
      resetResults()

    'click .no-years': (e) ->
      Session.set('years', [])
      $("[name=years]").prop('checked', false)
      resetResults()

    'click .all-medias': (e) ->
      Session.set('medias', medias)
      $("[name=medias]").prop('checked', true)
      resetResults()

    'click .no-medias': (e) ->
      Session.set('medias', [])
      $("[name=medias]").prop('checked', false)
      resetResults()


    'change [name=disciplines]': (e) ->
      value = $(e.target).closest('label').find('.text').text()
      currentDisciplines = Session.get('disciplines')
      if $(e.target).prop('checked')
        currentDisciplines.push(value)
        Session.set('disciplines', currentDisciplines)
        resetResults()
      else
        Session.set('disciplines', currentDisciplines.filter (e) -> e != value)
        resetResults()
      loadContentIfEnded()

    'change [name=years]': (e) ->
      value = $(e.target).closest('label').find('.text').text()
      currentYears = Session.get('years')
      if $(e.target).prop('checked')
        currentYears.push(value)
        Session.set('years', currentYears)
        resetResults()
      else
        Session.set('years', currentYears.filter (e) -> e != value)
        resetResults()
      loadContentIfEnded()

    'change [name=medias]': (e) ->
      value = $(e.target).closest('label').find('.text').text()
      currentMedias = Session.get('medias')
      if $(e.target).prop('checked')
        currentMedias.push(value)
        Session.set('medias', currentMedias)
        resetResults()
      else
        Session.set('medias', currentMedias.filter (e) -> e != value)
        resetResults()
      loadContentIfEnded()
  }

  $(window).scroll(loadContentIfEnded)

if Meteor.isServer
  Meteor.startup ->
    Articles.find({}).forEach (article) -> Articles.update(article._id, {$set: {rating: Math.floor((Math.random() * 5) + 1)}})
    Articles.find({}).forEach (article) -> Articles.update(article._id, {$set: {created_at: +(new Date())-(Math.random() * 100000000000) }})
  build_query = (disciplines, years, medias, keywords) ->
    query =
      disciplines: {$in: disciplines}
      years: {$in: years}
      media: {$in: medias}
    search_fields = ['title','summary','tags', 'produced_by', 'suggested_by']
    search_query = []

    if keywords && keywords != ''
      search_fields.forEach (field) ->
        search_keywords = {}
        search_keywords[field] = {$regex: keywords.split(' ').join('|'), $options: 'i'}
        search_query.push search_keywords
      query['$or'] = search_query
    query

  Meteor.methods
    articles_found: (disciplines, years, medias, keywords) ->
      query = build_query(disciplines, years, medias, keywords)
      Articles.find(query).count()

  Articles._ensureIndex({title: 1, summary: 1, tags: 1, produced_by: 1, suggested_by: 1}, {name: 'Search'})
  Meteor.publish "articles", (disciplines, years, medias, keywords, limit, sort_field, sort_order) ->
    query = build_query(disciplines, years, medias, keywords)
    options = {limit: limit, sort: {}}
    options.sort[sort_field] = sort_order
    Articles.find(query, options)
