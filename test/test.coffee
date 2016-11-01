path = require("path")
Helper = require("hubot-test-helper")
expect = require("chai").expect
http = require("http")
querystring = require("querystring")
nock = require("nock")

helper = new Helper("./../src/index.coffee")

describe "info rut", ->
  postData = querystring.stringify
    app: "bot"
    user: "user@mail.com"
    head: "1234567"
    release: "v1"
  postOptions =
    hostname: "localhost"
    port: 8080
    path: "/heroku/deploy"
    method: "POST"
    headers:
      "Content-Type": "application/x-www-form-urlencoded"
      "Content-Length": Buffer.byteLength(postData)
  process.env.GITHUB_USER = "user"
  process.env.GITHUB_REPO_NAME = "repo"

  beforeEach ->
    @room = helper.createRoom()
    @room.robot.adapter.client =
      rtm:
        dataStore:
          getChannelByName: (to) ->
            channels =
              "#random": {id: "R00000001", name: "random"}
            return channels[to]
  afterEach ->
    @room.destroy()

  context "POST /heroku/deploy", ->
    beforeEach (done) ->
      @room.robot.adapter.client.web =
        chat:
          postMessage: (channel, text, options) =>
            @postMessage =
              channel: channel
              text: text
              options: options
            done()
      nock("https://api.github.com")
        .get("/repos/user/repo/commits/1234567")
        .reply 200, JSON.stringify
          commit:
            author: {name: "user"}
            message: "Merge pull request #1"
          html_url: "https://github.com/user/repo/commit/1234567"
          author:
            avatar_url: "https://avatars.githubusercontent.com/u/123456?v=3"
            html_url: "https://github.com/user"
      req = http.request postOptions, (@response) => done()
      req.on "error", done
      req.write(postData)
      req.end()

    it "responds with status 200 and results", ->
      @room.robot.on "postMessage", (channel, text, options) ->
        expect(@postMessage.channel).to.equal "random"
        expect(@postMessage.text).to.be.null
        expect(@postMessage.options).to.equal "random"
        expect(@postMessage.options.as_user).to.be.true
        expect(@postMessage.options.link_names).to.equal 1
        expect(@postMessage.options.attachments).to.equal [
          fallback: "Deploy bot v1 (1234567)"
          color: "#36a64f"
          author_name: "user"
          author_link: "https://github.com/user"
          author_icon: "https://avatars.githubusercontent.com/u/123456?v=3"
          title: "Deploy bot v1 (1234567)"
          title_link: "https://github.com/user/repo/commit/1234567"
          text: "Merge pull request #1"
        ]

  context "POST /heroku/deploy error", ->
    beforeEach (done) ->
      nock("https://api.github.com")
        .get("/repos/user/repo/commits/1234567")
        .replyWithError("something awful happened")
      @room.robot.on "error", (@apiError) => done()
      req = http.request postOptions, (@response) => done()
      req.on "error", done
      req.write(postData)
      req.end()

    it "responds with status 200 and results", ->
      expect(@apiError.message).to.equal "something awful happened"

  context "POST /heroku/deploy redirect", ->
    beforeEach (done) ->
      nock("https://api.github.com")
        .get("/repos/user/repo/commits/1234567")
        .reply(302)
      @room.robot.on "error", (@apiError) => done()
      req = http.request postOptions, (@response) => done()
      req.on "error", done
      req.write(postData)
      req.end()

    it "responds with status 200 and results", ->
      expect(@apiError.message).to.equal "Error response code 302"
