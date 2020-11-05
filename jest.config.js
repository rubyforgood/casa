// For a detailed explanation regarding each configuration property, visit:
// https://jestjs.io/docs/en/configuration.html

module.exports = {
  testPathIgnorePatterns: [
    '<rootDir>/app/javascript/__tests__/setup-jest.js'
  ],
  moduleNameMapper: {
    '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$': '<rootDir>/__mocks__/fileMock.js',
    '\\.(css|less)$': '<rootDir>/__mocks__/styleMock.js'
  },
  setupFiles: ['<rootDir>/app/javascript/__tests__/setup-jest.js'],
  testRegex: ['app/javascript/__tests__']
}
