'use strict'

const { describe, it, beforeEach, afterEach } = require('mocha')
const Helper = require('hubot-test-helper')
const { expect } = require('chai')
const http = require('http')
const querystring = require('querystring')
const nock = require('nock')

const helper = new Helper('../src/index.js')

describe('info rut', function () {
  const postData = querystring.stringify({
    app: 'bot',
    user: 'user@mail.com',
    head: '1234567',
    release: 'v1'
  })
  const postOptions = {
    hostname: 'localhost',
    port: 8080,
    path: '/heroku/deploy',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': Buffer.byteLength(postData)
    }
  }
  process.env.GITHUB_USER = 'user'
  process.env.GITHUB_REPO_NAME = 'repo'

  beforeEach(() => {
    this.room = helper.createRoom()
    this.room.robot.adapter.client = {
      rtm: {
        dataStore: {
          getChannelByName (to) {
            const channels = { '#random': { id: 'R00000001', name: 'random' } }
            return channels[to]
          }
        }
      }
    }
  })
  afterEach(() => {
    this.room.destroy()
  })

  describe('POST /heroku/deploy', () => {
    beforeEach(done => {
      this.room.robot.adapter.client.web = {
        chat: {
          postMessage: (channel, text, options) => {
            this.postMessage = {
              channel,
              text,
              options
            }
            done()
          }
        }
      }
      nock('https://api.github.com')
        .get('/repos/user/repo/commits/1234567')
        .reply(
          200,
          JSON.stringify({
            commit: {
              author: { name: 'user' },
              message: 'Merge pull request #1'
            },
            html_url: 'https://github.com/user/repo/commit/1234567',
            author: {
              avatar_url: 'https://avatars.githubusercontent.com/u/123456?v=3',
              html_url: 'https://github.com/user'
            }
          })
        )
      const req = http.request(postOptions, response => {
        this.response = response
        done()
      })
      req.on('error', done)
      req.write(postData)
      req.end()
    })

    it('responds with status 200 and results', () => {
      this.room.robot.on('postMessage', (channel, text, options) => {
        expect(this.postMessage.channel).to.equal('random')
        expect(this.postMessage.text).to.be.a('null')
        expect(this.postMessage.options).to.equal('random')
        expect(this.postMessage.options.as_user).to.equal(true)
        expect(this.postMessage.options.link_names).to.equal(1)
        expect(this.postMessage.options.attachments).to.equal([
          {
            fallback: 'Deploy bot v1 (1234567)',
            color: '#36a64f',
            author_name: 'user',
            author_link: 'https://github.com/user',
            author_icon: 'https://avatars.githubusercontent.com/u/123456?v=3',
            title: 'Deploy bot v1 (1234567)',
            title_link: 'https://github.com/user/repo/commit/1234567',
            text: 'Merge pull request #1'
          }
        ])
      })
    })
  })

  describe('POST /heroku/deploy error', () => {
    beforeEach(done => {
      nock('https://api.github.com')
        .get('/repos/user/repo/commits/1234567')
        .replyWithError('something awful happened')
      this.room.robot.on('error', apiError => {
        this.apiError = apiError
        done()
      })
      const req = http.request(postOptions, response => {
        this.response = response
        done()
      })
      req.on('error', done)
      req.write(postData)
      req.end()
    })

    it('responds with status 200 and results', () => {
      expect(this.apiError.message).to.equal('something awful happened')
    })
  })

  describe('POST /heroku/deploy redirect', () => {
    beforeEach(done => {
      nock('https://api.github.com')
        .get('/repos/user/repo/commits/1234567')
        .reply(302)
      this.room.robot.on('error', apiError => {
        this.apiError = apiError
        done()
      })
      const req = http.request(postOptions, response => {
        this.response = response
        done()
      })
      req.on('error', done)
      req.write(postData)
      req.end()
    })

    it('responds with status 200 and results', () => {
      expect(this.apiError.message).to.equal('Error response code 302')
    })
  })
})
