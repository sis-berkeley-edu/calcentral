'use strict';

const baseConfig = require('./base.config.js');
const webpackMerge = require('webpack-merge');
const path = require('path');

module.exports = webpackMerge(baseConfig, {
  mode: 'production',
  module: {
    rules: [{
      test: /\.scss$/,
      use: ['style-loader', 'css-loader', 'sass-loader']
    }, {
      test: /\.css$/,
      use: ['style-loader', 'css-loader']
    }, {
      test: /\.html$/,
      exclude: [
        path.resolve(__dirname, '../src/base.html'),
        path.resolve(__dirname, '../src/bcourses_embedded.html'),
        path.resolve(__dirname, '../src/index-junction.html'), 
        path.resolve(__dirname, '../src/index-main.html')
      ],
      use: [
        { loader: 'ngtemplate-loader',
          options: {
            module: 'templates',
            relativeTo: '/src/assets/templates/',
            requireAngular: true
          }
        },
        { loader: 'html-loader',
          options: {
            attrs: ['img:data-src'],
            minimize: true
          }
        }
      ]
    }]
  }
});
