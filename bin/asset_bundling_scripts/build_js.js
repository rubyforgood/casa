#!/usr/bin/env node

const CLIArgs = process.argv.slice(2)
const isWatching = CLIArgs.includes('--watch')

const esbuild = require('esbuild')
const logger = require('./logger.js')

const watchingConsoleLogger = [{
  name: 'watching-console-logger',
  setup (build) {
    build.onEnd(result => {
      if (result.errors.length) {
        logger.error('watch build failed:')
        logger.error(`  build failed with ${result.errors.length} errors`)

        for (const error of result.errors) {
          logger.error('  Error:')
          logger.error(JSON.stringify(error, null, 2))
        }
      } else {
        logger.info('watch build succeeded:')
        logger.info(JSON.stringify(result, null, 2))
      }
    })
  }
}]

async function main () {
  const context = await esbuild.context({
    entryPoints: ['app/javascript/application.js', 'app/javascript/all_casa_admin.js'],
    outdir: 'app/assets/builds',
    bundle: true,
    plugins: watchingConsoleLogger
  })

  if (isWatching) {
    await context.watch()
  } else {
    await context.rebuild()
    await context.dispose()
  }
}

main().catch((e) => {
  console.error(e.message)
  process.exit(1)
})
