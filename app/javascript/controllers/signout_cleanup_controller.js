import Cookies from 'js-cookie'
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  cookies (event) {
    event.preventDefault()
    const { cookies } = event.params
    cookies.forEach(cookie => Cookies.remove(cookie))
    window.location.href = event.target.href
  }
}
