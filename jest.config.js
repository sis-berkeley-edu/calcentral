module.exports = {
  moduleNameMapper: {
    '\\.scss$': require.resolve('./src/test/style-mock.js'),
    '\\.css$': require.resolve('./src/test/style-mock.js'),
  },
  testPathIgnorePatterns: ['/node_modules/', '/vendor/'],
};
