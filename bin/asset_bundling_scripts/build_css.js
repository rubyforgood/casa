#!/usr/bin/env node

const sass = require('sass')

const compiledCSS = sass.renderSync({
  file: "app/javascript/src/stylesheets/application.scss"
});

//console.log(compiledCSS.css.toString())
