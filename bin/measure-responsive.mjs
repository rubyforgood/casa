#!/usr/bin/env node
// Measure horizontal overflow of local HTML pages at true viewport widths.
//
// Why this exists: headless Chrome clamps its minimum window to ~500px, so
// `--window-size=375` silently measures 500px and media queries never reach
// phone width. This drives Chrome over the DevTools Protocol and uses
// Emulation.setDeviceMetricsOverride, which forces the real viewport width, so
// `md:`/`lg:` breakpoints evaluate exactly as they do on a device.
//
// For each page it reports `documentElement.scrollWidth / innerWidth` (the
// page-fit authority) and, if any element's rendered right edge exceeds the
// viewport, the widest offender (clipped sub-2px boxes such as sr-only captions
// are skipped, and elements inside their own `overflow-x-auto` scroller still
// surface so a data table that only scrolls horizontally is caught).
//
// Usage:
//   bin/measure-responsive.mjs <width,width,...> <file.html> [file.html ...]
//   bin/measure-responsive.mjs tmp/design-preview/*.html            # default widths
//
// Requires: a `google-chrome` on PATH and Node >= 22 (built-in WebSocket).
import { spawn } from 'node:child_process'

/* global WebSocket */

const args = process.argv.slice(2)
const DEFAULT_WIDTHS = [375, 414, 768, 1024, 1280]
const widths = /^[\d,]+$/.test(args[0] ?? '') ? args.shift().split(',').map(Number) : DEFAULT_WIDTHS
const files = args
if (files.length === 0) {
  console.error('usage: bin/measure-responsive.mjs [width,width,...] <file.html> [file.html ...]')
  process.exit(1)
}
const PORT = 9222
const HOST = `127.0.0.1:${PORT}`

const EXPR = '(function(){var m=0,t="";var e=document.body.getElementsByTagName("*");for(var i=0;i<e.length;i++){var x=e[i];var r=x.getBoundingClientRect();if(r.width<2)continue;if(r.right>innerWidth+2&&r.right>m){m=r.right;t=x.tagName+"."+((x.className&&x.className.split)?x.className.split(" ").slice(0,2).join("."):"");}}return "W"+document.documentElement.scrollWidth+"/"+innerWidth+(m?" OVERFLOW "+t+" "+Math.round(m):" ok");})()'

function cdp (wsUrl) {
  const ws = new WebSocket(wsUrl)
  let id = 0
  const pending = new Map()
  const waiters = []
  ws.onmessage = (ev) => {
    const msg = JSON.parse(ev.data)
    if (msg.id && pending.has(msg.id)) { pending.get(msg.id)(msg.result); pending.delete(msg.id) }
    if (msg.method) waiters.forEach((w) => w(msg.method))
  }
  const ready = new Promise((resolve) => { ws.onopen = resolve })
  return {
    ready,
    send: (method, params = {}) => new Promise((resolve) => { id++; pending.set(id, resolve); ws.send(JSON.stringify({ id, method, params })) }),
    waitFor: (method) => new Promise((resolve) => waiters.push((m) => { if (m === method) resolve() })),
    close: () => ws.close()
  }
}

async function measure (fileUrl, width) {
  const res = await fetch(`http://${HOST}/json/new?about:blank`, { method: 'PUT' })
  const target = await res.json()
  const c = cdp(target.webSocketDebuggerUrl)
  await c.ready
  await c.send('Page.enable')
  await c.send('Emulation.setDeviceMetricsOverride', { width, height: 900, deviceScaleFactor: 1, mobile: false })
  const loaded = c.waitFor('Page.loadEventFired')
  await c.send('Page.navigate', { url: fileUrl })
  await Promise.race([loaded, new Promise((resolve) => setTimeout(resolve, 4000))])
  await new Promise((resolve) => setTimeout(resolve, 400))
  const { result } = await c.send('Runtime.evaluate', { expression: EXPR, returnByValue: true })
  c.close()
  await fetch(`http://${HOST}/json/close/${target.id}`)
  return result.value
}

async function waitForChrome () {
  for (let i = 0; i < 40; i++) {
    try { await fetch(`http://${HOST}/json/version`); return } catch { await new Promise((resolve) => setTimeout(resolve, 250)) }
  }
  throw new Error('Chrome did not open a debugging port')
}

const chrome = spawn('google-chrome', [
  '--headless=new', '--no-sandbox', '--disable-gpu',
  `--remote-debugging-port=${PORT}`, '--remote-allow-origins=*', 'about:blank'
], { stdio: 'ignore' })
process.on('exit', () => chrome.kill())

try {
  await waitForChrome()
  for (const f of files) {
    const abs = f.startsWith('/') ? f : `${process.cwd()}/${f}`
    const name = f.split('/').pop().replace(/\.html$/, '')
    for (const w of widths) {
      const out = await measure('file://' + abs, w).catch((e) => 'ERR ' + e.message)
      console.log(`  ${name} @${w}px -> ${out}`)
    }
  }
} finally {
  chrome.kill()
}
