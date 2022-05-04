#!/usr/bin/env node

const fileSystem = require('fs')
const logger = require('./logger.js')
const sass = require('sass')

const compiledCSS = sass.renderSync({
  file: 'app/assets/stylesheets/application.scss'
})

fileSystem.writeFile('./app/assets/builds/application.css', compiledCSS.css.toString(), function (err) {
  if (err) {
    logger.error(err)
    return
  }

  logger.info('CSS generated successfully')
})
