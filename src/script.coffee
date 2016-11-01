# Description
#   Obtiene el nombre de la persona o empresa del RUT consultado y viceversa
#
# Dependencies:
#   None
#
# Configuration:
#   GITHUB_USER, GITHUB_REPO_NAME, DEPLOY_CHANNEL
#
# Commands:
#   None
#
# Author:
#   lgaticaq

getCommit = (robot, sha) ->
  return new Promise (resolve, reject) ->
    user = process.env.GITHUB_USER
    repo = process.env.GITHUB_REPO_NAME
    robot.http("https://api.github.com/repos/#{user}/#{repo}/commits/#{sha}")
      .header("User-Agent", robot.name)
      .get() (err, res, body) ->
        if err
          reject(err)
        else if res.statusCode isnt 200
          reject(new Error("Error response code #{res.statusCode}"))
        else
          resolve(JSON.parse(body))

module.exports = (robot) ->
  robot.router.post "/heroku/deploy", (req, res) ->
    channelName = process.env.DEPLOY_CHANNEL or "#random"
    channel = robot.adapter.client.rtm.dataStore.getChannelByName(channelName)
    message = "Deploy #{req.body.app} #{req.body.release} (#{req.body.release})"
    getCommit(robot, req.body.head)
      .then (data) ->
        options =
          as_user: true
          link_names: 1
          attachments: [
            fallback: message
            color: "#36a64f"
            author_name: data.commit.author.name
            author_link: data.author.html_url
            author_icon: data.author.avatar_url
            title: message
            title_link: data.html_url
            text: data.commit.message
          ]
        robot.adapter.client.web.chat.postMessage channel.name, null, options
      .catch (err) ->
        robot.emit "error", err
