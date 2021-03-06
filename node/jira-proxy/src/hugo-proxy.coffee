express   = require 'express'
http      = require('http')
url       = require('url')

class Hugo_Proxy
  constructor: (options)->
    @.options       = options || {}
    @.hugo_Server   = 'localhost'
    @.port          = 1313
    @.app           = @.options.app
    @.router        = express.Router()

  add_Routes: ()=>
    @.handler_404()
    @.handler_star()

  handler_404: ()->
    @.app.get? '/404',  (req, res)=>
      #console.log 'handling 404 for ' + req.headers
      res.json
        status: 'handling 404'
        query : req.query


  handler_star:()->
    @.app.get? '/*',  (req, res)=>
      options         = url.parse(req.url);
      options.host    = @.hugo_Server
      options.port    = @.port
      options.headers = req.headers;
      options.method  = req.method;
      #console.log "proxying request to #{options.host}:#{options.port}#{options.path}"
      connector = http.request options, (serverRes)->
        #serverRes.pause()
        if serverRes.statusCode is 404
          res.redirect "/404?url=#{req.url}"
#          res.json
#            status: 'its a 404'
#            url   : req.url
        else
          serverRes.pipe(res, {end:true})
          #serverRes.resume();
      req.pipe(connector, {end:true});
    @



module.exports = Hugo_Proxy