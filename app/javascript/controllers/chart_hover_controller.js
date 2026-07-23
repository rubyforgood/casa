import { Controller } from '@hotwired/stimulus'

// Crosshair + tooltip for a server-rendered SVG line chart. Reads the chart
// geometry from the config value; every value is also in the table twin, so this
// is progressive enhancement, not the only way to read the data.
export default class extends Controller {
  static values = { config: Object }
  static targets = ['tip']

  connect () {
    this.cfg = this.configValue
    this.svg = this.element.querySelector('svg')
    if (!this.svg || !this.cfg || !this.cfg.series) return
    const ns = 'http://www.w3.org/2000/svg'
    this.cross = document.createElementNS(ns, 'line')
    this.cross.setAttribute('stroke', '#94a3b8')
    this.cross.setAttribute('stroke-width', '1')
    this.cross.setAttribute('stroke-dasharray', '3 3')
    this.cross.setAttribute('y1', this.cfg.plotTop)
    this.cross.setAttribute('y2', this.cfg.plotBottom)
    this.cross.style.opacity = '0'
    this.cross.style.pointerEvents = 'none'
    this.svg.appendChild(this.cross)
    this.dots = this.cfg.series.map((s) => {
      const dot = document.createElementNS(ns, 'circle')
      dot.setAttribute('r', '4.5')
      dot.setAttribute('fill', s.color)
      dot.setAttribute('stroke', '#fff')
      dot.setAttribute('stroke-width', '2')
      dot.style.opacity = '0'
      dot.style.pointerEvents = 'none'
      this.svg.appendChild(dot)
      return dot
    })
    this.onMove = this.onMove.bind(this)
    this.onLeave = this.onLeave.bind(this)
    this.svg.addEventListener('pointermove', this.onMove)
    this.svg.addEventListener('pointerleave', this.onLeave)
  }

  disconnect () {
    if (!this.svg) return
    this.svg.removeEventListener('pointermove', this.onMove)
    this.svg.removeEventListener('pointerleave', this.onLeave)
  }

  onMove (event) {
    const point = this.svg.createSVGPoint()
    point.x = event.clientX
    point.y = event.clientY
    const x = point.matrixTransform(this.svg.getScreenCTM().inverse()).x
    let index = 0
    let best = Infinity
    this.cfg.xs.forEach((xv, idx) => {
      const distance = Math.abs(xv - x)
      if (distance < best) {
        best = distance
        index = idx
      }
    })
    const cx = this.cfg.xs[index]
    this.cross.setAttribute('x1', cx)
    this.cross.setAttribute('x2', cx)
    this.cross.style.opacity = '1'
    this.cfg.series.forEach((s, si) => {
      this.dots[si].setAttribute('cx', cx)
      this.dots[si].setAttribute('cy', s.ys[index])
      this.dots[si].style.opacity = '1'
    })
    if (!this.hasTipTarget) return
    const tip = this.tipTarget
    tip.replaceChildren()
    const month = document.createElement('div')
    month.className = 'mb-1 text-[11px] font-bold text-slate-300'
    month.textContent = this.cfg.labels[index]
    tip.appendChild(month)
    this.cfg.series.forEach((s) => {
      const row = document.createElement('div')
      row.className = 'flex items-center gap-1.5 leading-relaxed'
      const key = document.createElement('span')
      key.className = 'h-0.5 w-3.5 flex-none rounded'
      key.style.background = s.color
      const value = document.createElement('span')
      value.className = 'font-bold tabular-nums'
      value.textContent = s.values[index]
      const name = document.createElement('span')
      name.className = 'text-slate-300'
      name.textContent = s.name
      row.append(key, value, name)
      tip.appendChild(row)
    })
    tip.style.opacity = '1'
    const rect = this.element.getBoundingClientRect()
    let left = event.clientX - rect.left + 14
    if (left + tip.offsetWidth > rect.width) {
      left = event.clientX - rect.left - tip.offsetWidth - 14
    }
    tip.style.left = `${left}px`
    tip.style.top = `${event.clientY - rect.top + 14}px`
  }

  onLeave () {
    this.cross.style.opacity = '0'
    this.dots.forEach((dot) => { dot.style.opacity = '0' })
    if (this.hasTipTarget) this.tipTarget.style.opacity = '0'
  }
}
