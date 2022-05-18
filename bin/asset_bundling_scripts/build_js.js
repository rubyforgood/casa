#!/usr/bin/env node

const CLIArgs = process.argv.slice(2)

const esbuild = require('esbuild')
const logger = require('./logger.js')

esbuild.build({
  entryPoints: ['app/javascript/application.js'],
  outdir: 'app/assets/builds',
  bundle: true,
  watch: CLIArgs.includes('--watch')
}).then(result => {
  logger.info('application.js built successfully')
  logger.info('watching for changes')
}).catch((err) => {
  logger.error('failed to build application.js')
  logger.error(err)
})
