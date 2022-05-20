#!/usr/bin/env node

const CLIArgs = process.argv.slice(2)
const isWatching = CLIArgs.includes('--watch')

const esbuild = require('esbuild')
const logger = require('./logger.js')

esbuild.build({
  entryPoints: ['app/javascript/application.js', 'app/javascript/all_casa_admin.js'],
  outdir: 'app/assets/builds',
  bundle: true,
  watch: isWatching
}).then(result => {
  logger.info('application.js, all_casa_admin.js built successfully')

  if (isWatching) {
    logger.info('watching for changes')
  }
}).catch((err) => {
  logger.error('failed to build application.js')
  logger.error(err)
})
