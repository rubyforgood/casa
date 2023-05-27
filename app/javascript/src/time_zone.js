import Cookies from 'js-cookie'
import jstz from 'jstz'

// Rails doesn't support every timezone that Intl supports
export function findTimeZone () {
  const oldIntl = window.Intl
  try {
    window.Intl = undefined
    const tz = jstz.determine().name()
    window.Intl = oldIntl
    return tz
  } catch (e) {
    // sometimes (on android) you can't override intl
    return jstz.determine().name()
  }
}

document.addEventListener('DOMContentLoaded', () => {
  Cookies.set('browser_time_zone', findTimeZone(), { expires: 365, path: '/', secure: true, sameSite: 'strict' })
})
