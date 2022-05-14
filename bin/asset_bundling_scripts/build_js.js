#!/usr/bin/env node

const esbuild = require('esbuild')
const logger = require('./logger.js')

esbuild.build({
  entryPoints: ['app/javascript/application.js'],
  outdir: 'app/assets/builds',
  bundle: true,
  watch: true
}).then(result => {
  logger.info('application.js built successfully')
  logger.info('watching for changes')
})
