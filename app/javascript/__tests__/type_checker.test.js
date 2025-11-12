/* eslint-env jest */
/**
 * @jest-environment jsdom
 */

const TypeChecker = require('../src/type_checker')

describe('TypeChecker', () => {
  describe('checkNonEmptyJQueryObject', () => {
    beforeEach(() => {
      document.body.innerHTML = '<div id="test-element"></div>'
    })

    test('accepts a non-empty jQuery object', () => {
      const element = $('#test-element')
      expect(() => {
        TypeChecker.checkNonEmptyJQueryObject(element, 'element')
      }).not.toThrow()
    })

    test('throws TypeError when passed a non-jQuery object', () => {
      expect(() => {
        TypeChecker.checkNonEmptyJQueryObject('string', 'element')
      }).toThrow(TypeError)
      expect(() => {
        TypeChecker.checkNonEmptyJQueryObject('string', 'element')
      }).toThrow('Param element must be a jQuery object')
    })

    test('throws TypeError when passed null', () => {
      expect(() => {
        TypeChecker.checkNonEmptyJQueryObject(null, 'element')
      }).toThrow(TypeError)
    })

    test('throws TypeError when passed undefined', () => {
      expect(() => {
        TypeChecker.checkNonEmptyJQueryObject(undefined, 'element')
      }).toThrow(TypeError)
    })

    test('throws TypeError when passed a plain object', () => {
      expect(() => {
        TypeChecker.checkNonEmptyJQueryObject({}, 'element')
      }).toThrow(TypeError)
    })

    test('throws ReferenceError when jQuery object contains no elements', () => {
      const emptyElement = $('#non-existent')
      expect(() => {
        TypeChecker.checkNonEmptyJQueryObject(emptyElement, 'element')
      }).toThrow(ReferenceError)
      expect(() => {
        TypeChecker.checkNonEmptyJQueryObject(emptyElement, 'element')
      }).toThrow('Param element contains no elements')
    })
  })

  describe('checkNonEmptyString', () => {
    test('accepts a non-empty string', () => {
      expect(() => {
        TypeChecker.checkNonEmptyString('hello', 'myString')
      }).not.toThrow()
    })

    test('throws TypeError when passed a non-string', () => {
      expect(() => {
        TypeChecker.checkNonEmptyString(123, 'myString')
      }).toThrow(TypeError)
      expect(() => {
        TypeChecker.checkNonEmptyString(123, 'myString')
      }).toThrow('Param myString must be a string')
    })

    test('throws TypeError when passed null', () => {
      expect(() => {
        TypeChecker.checkNonEmptyString(null, 'myString')
      }).toThrow(TypeError)
    })

    test('throws TypeError when passed undefined', () => {
      expect(() => {
        TypeChecker.checkNonEmptyString(undefined, 'myString')
      }).toThrow(TypeError)
    })

    test('throws RangeError when passed an empty string', () => {
      expect(() => {
        TypeChecker.checkNonEmptyString('', 'myString')
      }).toThrow(RangeError)
      expect(() => {
        TypeChecker.checkNonEmptyString('', 'myString')
      }).toThrow('Param myString cannot be empty string')
    })
  })

  describe('checkObject', () => {
    test('accepts a plain object', () => {
      expect(() => {
        TypeChecker.checkObject({}, 'myObject')
      }).not.toThrow()
    })

    test('accepts an object with properties', () => {
      expect(() => {
        TypeChecker.checkObject({ key: 'value' }, 'myObject')
      }).not.toThrow()
    })

    test('throws TypeError when passed a string', () => {
      expect(() => {
        TypeChecker.checkObject('string', 'myObject')
      }).toThrow(TypeError)
      expect(() => {
        TypeChecker.checkObject('string', 'myObject')
      }).toThrow('Param myObject is not an object')
    })

    test('throws TypeError when passed a number', () => {
      expect(() => {
        TypeChecker.checkObject(123, 'myObject')
      }).toThrow(TypeError)
    })

    test('throws TypeError when passed an array', () => {
      expect(() => {
        TypeChecker.checkObject([1, 2, 3], 'myObject')
      }).toThrow(TypeError)
      expect(() => {
        TypeChecker.checkObject([1, 2, 3], 'myObject')
      }).toThrow('Param myObject is not an object')
    })

    test('throws TypeError when passed null', () => {
      expect(() => {
        TypeChecker.checkObject(null, 'myObject')
      }).toThrow(TypeError)
    })

    test('throws TypeError when passed undefined', () => {
      expect(() => {
        TypeChecker.checkObject(undefined, 'myObject')
      }).toThrow(TypeError)
    })
  })

  describe('checkPositiveInteger', () => {
    test('accepts zero', () => {
      expect(() => {
        TypeChecker.checkPositiveInteger(0, 'myNumber')
      }).not.toThrow()
    })

    test('accepts positive integers', () => {
      expect(() => {
        TypeChecker.checkPositiveInteger(1, 'myNumber')
      }).not.toThrow()
      expect(() => {
        TypeChecker.checkPositiveInteger(100, 'myNumber')
      }).not.toThrow()
    })

    test('throws TypeError when passed a float', () => {
      expect(() => {
        TypeChecker.checkPositiveInteger(1.5, 'myNumber')
      }).toThrow(TypeError)
      expect(() => {
        TypeChecker.checkPositiveInteger(1.5, 'myNumber')
      }).toThrow('Param myNumber is not an integer')
    })

    test('throws TypeError when passed a string', () => {
      expect(() => {
        TypeChecker.checkPositiveInteger('123', 'myNumber')
      }).toThrow(TypeError)
    })

    test('throws TypeError when passed NaN', () => {
      expect(() => {
        TypeChecker.checkPositiveInteger(NaN, 'myNumber')
      }).toThrow(TypeError)
    })

    test('throws RangeError when passed a negative integer', () => {
      expect(() => {
        TypeChecker.checkPositiveInteger(-1, 'myNumber')
      }).toThrow(RangeError)
      expect(() => {
        TypeChecker.checkPositiveInteger(-1, 'myNumber')
      }).toThrow('Param myNumber cannot be negative')
    })

    test('throws RangeError when passed a large negative integer', () => {
      expect(() => {
        TypeChecker.checkPositiveInteger(-100, 'myNumber')
      }).toThrow(RangeError)
    })
  })

  describe('checkString', () => {
    test('accepts a string', () => {
      expect(() => {
        TypeChecker.checkString('hello', 'myString')
      }).not.toThrow()
    })

    test('accepts an empty string', () => {
      expect(() => {
        TypeChecker.checkString('', 'myString')
      }).not.toThrow()
    })

    test('throws TypeError when passed a number', () => {
      expect(() => {
        TypeChecker.checkString(123, 'myString')
      }).toThrow(TypeError)
      expect(() => {
        TypeChecker.checkString(123, 'myString')
      }).toThrow('Param myString must be a string')
    })

    test('throws TypeError when passed null', () => {
      expect(() => {
        TypeChecker.checkString(null, 'myString')
      }).toThrow(TypeError)
    })

    test('throws TypeError when passed undefined', () => {
      expect(() => {
        TypeChecker.checkString(undefined, 'myString')
      }).toThrow(TypeError)
    })

    test('throws TypeError when passed an object', () => {
      expect(() => {
        TypeChecker.checkString({}, 'myString')
      }).toThrow(TypeError)
    })

    test('throws TypeError when passed an array', () => {
      expect(() => {
        TypeChecker.checkString([], 'myString')
      }).toThrow(TypeError)
    })
  })
})
