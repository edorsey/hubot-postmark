{Robot, Adapter, TextMessage}   = require("hubot")

http     = require "http"
qs       = require "querystring"
postmark = require "postmark"

class Postmark extends Adapter
  constructor: (@robot) ->
    @fromEmail = process.env.HUBOT_POSTMARK_FROM
    @client = new postmark.Client process.env.HUBOT_POSTMARK_KEY
    
    super @robot

  send: (envelope, strings...) ->
    message = strings.join "\n"
    
    email =
      "From": @fromEmail
      "To": envelope.user.id
      "Subject": envelope.message.subject
      "TextBody": message
      
    @client.sendEmail email, (err, success) ->
      if err
        console.log "Error sending reply SMS: #{err}"
      else
        console.log "Sending reply SMS: #{message} to #{user.id}"

  reply: (user, strings...) ->
    @send user, str for str in strings

  respond: (regex, callback) ->
    @hear regex, callback

  run: ->
    @robot.router.post "/hubot/email", (req, res) =>
      res.status 200
      res.send()
      
      user = @userForId req.body.From, name: req.body.FromName
        
      message = new TextMessage user, req.body.TextBody, req.body.MessageID
      message.subject = req.body.Subject
      
      console.log "MESSAGE", message
      @receive message
      
    @emit "connected"
    
module.exports = exports = {
  Postmark
}

exports.use = (robot) ->
  new Postmark robot

