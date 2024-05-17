// Object.keys({variable})[0]

module.exports = {
  // Checks if a variable is a JQuery object
  //  @param  {any}    variable The variable to be checked
  //  @param  {string} varName  The name of the variable to be checked
  //  @throws {TypeError} If variable is not a JQuery object
  //  @throws {ReferenceError} If variable is a JQuery object but points to no elements
  checkNonEmptyJQueryObject (variable, varName) {
    if (!(variable instanceof jQuery)) {
      throw new TypeError(`Param ${varName} must be a jQuery object`)
    }

    if (!variable.length) {
      throw new ReferenceError(`Param ${varName} contains no elements`)
    }
  },

  // Checks if a variable is a non empty string
  //  @param  {any}    variable The variable to be checked
  //  @param  {string} varName  The name of the variable to be checked
  //  @throws {TypeError} If variable is not a string
  //  @throws {RangeError} If variable is empty string
  checkNonEmptyString (variable, varName) {
    this.checkString(variable, varName)

    if (!(variable.length)) {
      throw new RangeError(`Param ${varName} cannot be empty string`)
    }
  },

  // Checks if a variable is an object
  //  @param  {any}    variable The variable to be checked
  //  @param  {string} varName  The name of the variable to be checked
  //  @throws {TypeError}  If variable is not an object
  checkObject (variable, varName) {
    if (typeof variable !== 'object' || Array.isArray(variable) || variable === null) {
      throw new TypeError(`Param ${varName} is not an object`)
    }
  },

  // Checks if a variable is a positive integer
  //  @param  {any}    variable The variable to be checked
  //  @param  {string} varName  The name of the variable to be checked
  //  @throws {TypeError}  If variable is not an integer
  //  @throws {RangeError} If variable is less than 0
  checkPositiveInteger (variable, varName) {
    if (!Number.isInteger(variable)) {
      throw new TypeError(`Param ${varName} is not an integer`)
    } else if (variable < 0) {
      throw new RangeError(`Param ${varName} cannot be negative`)
    }
  },

  // Checks if a variable is a string or not
  //  @param  {any}    variable The variable to be checked
  //  @param  {string} varName  The name of the variable to be checked
  //  @throws {TypeError} If variable is not a string
  checkString (variable, varName) {
    if (typeof variable !== 'string') {
      throw new TypeError(`Param ${varName} must be a string`)
    }
  }
}
