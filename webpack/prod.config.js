/* jshint esversion:6 */
/* jscs: disable  disallowSpacesInsideObjectBrackets */
/* jscs: disable  requirePaddingNewLinesInObjects */
/* jscs: disable  requireObjectKeysOnNewLine */
'use strict';

const baseConfig = require('./base.config.js');
const webpackMerge = require('webpack-merge');

module.exports = webpackMerge(baseConfig, {
  mode: 'production',
  module: {
    rules: [{
      test: /\.scss$/,
      use: ['style-loader', 'css-loader', 'sass-loader']
    }, {
      test: /\.css$/,
      use: ['style-loader', 'css-loader']
    }]
  }
});
