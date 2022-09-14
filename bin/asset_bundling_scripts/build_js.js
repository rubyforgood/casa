#!/usr/bin/env node

const CLIArgs = process.argv.slice(2)
const isWatching = CLIArgs.includes('--watch')

const esbuild = require('esbuild')
const logger = require('./logger.js')

const watchValue = isWatching ? {
  onRebuild(error, result) {
    if (error) {
      logger.error('watch build failed:')
      logger.error(error.stack)
    } else {
      logger.info('watch build succeeded:')
      logger.info(JSON.stringify(result))
    }
  }
} : false

esbuild.build({
  entryPoints: ['app/javascript/application.js', 'app/javascript/all_casa_admin.js'],
  outdir: 'app/assets/builds',
  bundle: true,
  watch: watchValue
}).then(result => {
  logger.info('application.js, all_casa_admin.js built successfully')

  if (isWatching) {
    logger.info('watching for changes')
  }
}).catch((err) => {
  logger.error('failed to build application.js')
  logger.error(err)
})
