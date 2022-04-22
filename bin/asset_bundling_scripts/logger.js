const defaultText = '\x1b[0m'
// const bright = '\x1b[1m'
// const dim = '\x1b[2m'
// const underscore = '\x1b[4m'
// const blink = '\x1b[5m'
// const reverse = '\x1b[7m'
// const hidden = '\x1b[8m'

// const textBlack = '\x1b[30m'
const textRed = '\x1b[31m'
// const textGreen = '\x1b[32m'
const textYellow = '\x1b[33m'
// const textBlue = '\x1b[34m'
// const textMagenta = '\x1b[35m'
const textCyan = '\x1b[36m'
// const textWhite = '\x1b[37m'

// const highlightBlack = '\x1b[40m'
// const highlightRed = '\x1b[41m'
// const highlightGreen = '\x1b[42m'
// const highlightYellow = '\x1b[43m'
// const highlightBlue = '\x1b[44m'
// const highlightMagenta = '\x1b[45m'
// const highlightCyan = '\x1b[46m'
// const highlightWhite = '\x1b[47m'

module.exports = {
  error: function (message) {
    if (typeof message !== 'string') {
      throw new TypeError('Param message must be a string')
    }

    console.error(textRed + message + defaultText)
  },

  info: function (message) {
    if (typeof message !== 'string') {
      throw new TypeError('Param message must be a string')
    }

    console.log(textCyan + message + defaultText)
  },

  warn: function (message) {
    if (typeof message !== 'string') {
      throw new TypeError('Param message must be a string')
    }

    console.warn(textYellow + message + defaultText)
  }
}
