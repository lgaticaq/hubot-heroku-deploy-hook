# hubot-heroku-deploy-hook

[![npm version](https://img.shields.io/npm/v/hubot-heroku-deploy-hook.svg?style=flat-square)](https://www.npmjs.com/package/hubot-heroku-deploy-hook)
[![npm downloads](https://img.shields.io/npm/dm/hubot-heroku-deploy-hook.svg?style=flat-square)](https://www.npmjs.com/package/hubot-heroku-deploy-hook)
[![Build Status](https://img.shields.io/travis/lgaticaq/hubot-heroku-deploy-hook.svg?style=flat-square)](https://travis-ci.org/lgaticaq/hubot-heroku-deploy-hook)
[![Coverage Status](https://img.shields.io/coveralls/lgaticaq/hubot-heroku-deploy-hook/master.svg?style=flat-square)](https://coveralls.io/github/lgaticaq/hubot-heroku-deploy-hook?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/github/lgaticaq/hubot-heroku-deploy-hook.svg?style=flat-square)](https://codeclimate.com/github/lgaticaq/hubot-heroku-deploy-hook)
[![dependency Status](https://img.shields.io/david/lgaticaq/hubot-heroku-deploy-hook.svg?style=flat-square)](https://david-dm.org/lgaticaq/hubot-heroku-deploy-hook#info=dependencies)
[![devDependency Status](https://img.shields.io/david/dev/lgaticaq/hubot-heroku-deploy-hook.svg?style=flat-square)](https://david-dm.org/lgaticaq/hubot-heroku-deploy-hook#info=devDependencies)

> A hubot script to get deploy hook from heroku

## Install

```bash
npm i -S hubot-heroku-deploy-hook
```

Add `["hubot-heroku-deploy-hook"]` in `external-scripts.json`.

Set `GITHUB_USER`, `GITHUB_REPO_NAME` and `DEPLOY_CHANNEL` in environment variable. `GITHUB_USER` and `GITHUB_REPO_NAME` get from `https://github.com/GITHUB_USER/GITHUB_REPO_NAME`. `DEPLOY_CHANNEL` is the channel to post notification (default `#random`).

## License

[MIT](https://tldrlegal.com/license/mit-license)
