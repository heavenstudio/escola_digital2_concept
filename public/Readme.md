Comandos úteis!

MONGO_URL=mongodb://localhost:27017/escola_digital meteor
Articles.find({}).forEach(function(article){ Articles.update(article._id, {$set: {rating: Math.floor((Math.random() * 5) + 1)}}) })
Articles.find({}).forEach(function(article){ Articles.update(article._id, {$set: {created_at: +(new Date())}}) })