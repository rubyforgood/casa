import $ from 'jquery'
global.$ = global.jQuery = $

// jsdom doesn't implement matchMedia; sweetalert2 (>=11.16) calls it during render
// to detect prefers-reduced-motion. Stub it so popups can be exercised in tests.
if (typeof window !== 'undefined' && !window.matchMedia) {
  window.matchMedia = (query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: () => {},
    removeListener: () => {},
    addEventListener: () => {},
    removeEventListener: () => {},
    dispatchEvent: () => false
  })
}
