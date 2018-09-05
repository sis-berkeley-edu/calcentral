'use strict';
const fs = require('fs');
const path = require('path');

const cleanWebpackPlugin = require('clean-webpack-plugin');
const htmlWebpackPlugin = require('html-webpack-plugin');

let paths = {
  source: {
    templates: {
      base: './src/base.html',
      bCoursesEmbedded: fs.readFileSync('./src/bcourses_embedded.html'),
      index: fs.readFileSync('./src/index-main.html'),
      indexJunction: fs.readFileSync('./src/index-junction.html')
    }
  },
  public: {
    assets: {
      fonts: './assets/fonts/',
      images: './assets/images/',
      javascripts: './assets/javascripts/'
    },
    templates: {
      bCoursesEmbedded: './bcourses_embedded.html',
      index: './index-main.html',
      indexJunction: './index-junction.html'
    }
  }
};

let pathsToClean = [
  paths.public.assets.fonts,
  paths.public.assets.images,
  paths.public.assets.javascripts,
  paths.public.templates.bCoursesEmbedded,
  paths.public.templates.index,
  paths.public.templates.indexJunction
];

module.exports = {
  entry: './src/assets/javascripts/index.js',
  output: {
    filename: 'assets/javascripts/application.js',
    path: path.resolve(__dirname, '../public/')
  },
  module: {
    rules: [
      { test: /\.js$/,
        exclude: path.resolve(__dirname, '../node_modules'),
        use: [
          { loader: 'ng-annotate-loader',
            options: {
              add: true
            }
          },
          { loader: 'babel-loader' }
        ]
      },
      { test: /\.(png|svg|jpg|gif|ico)$/,
        loader: 'url-loader',
        options: {
          fallback: 'file-loader',
          // sets our base64 encoding threshold at 8KB
          limit: 8 * 1024,
          name: '[name].[ext]',
          outputPath: 'assets/images/'
        }
      },
      { test: /\.(woff|woff2|eot|ttf|otf)$/,
        loader: 'url-loader',
        options: {
          fallback: 'file-loader',
          limit: 8 * 1024,
          name: '[name].[ext]',
          outputPath: 'assets/fonts/'
        }
      }
    ]
  },
  plugins: [
    new cleanWebpackPlugin(pathsToClean, { root: path.resolve(__dirname, '../public/') }),
    new htmlWebpackPlugin({
      filename: paths.public.templates.bCoursesEmbedded,
      inject: false,
      injectedHtml: paths.source.templates.bCoursesEmbedded,
      template: paths.source.templates.base
    }),
    new htmlWebpackPlugin({
      filename: paths.public.templates.indexJunction,
      inject: false,
      injectedHtml: paths.source.templates.indexJunction,
      template: paths.source.templates.base
    }),
    new htmlWebpackPlugin({
      filename: paths.public.templates.index,
      inject: false,
      injectedHtml: paths.source.templates.index,
      template: paths.source.templates.base
    })
  ]
};
