// Object.keys({variable})[0]

module.exports = {

  // Checks if a variable is a string or not
  //  @param    {any}    variable The variable to be checked
  //  @param    {string} varName  The name of the variable to be checked
  //  @throws   {TypeError} If variable is not a string
  checkString (variable, varName) {
    if (typeof variable !== 'string') {
      throw new TypeError(`Param ${varName} must be a string`)
    }
  }
}
