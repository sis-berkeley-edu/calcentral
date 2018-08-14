/* jshint esversion:6 */
/* jscs: disable  disallowSpacesInsideObjectBrackets */
/* jscs: disable  requirePaddingNewLinesInObjects */
/* jscs: disable  requireObjectKeysOnNewLine */
const fs = require('fs');
const path = require('path');

const cleanWebpackPlugin = require('clean-webpack-plugin');
const copyWebpackPlugin = require('copy-webpack-plugin');
const htmlWebpackPlugin = require('html-webpack-plugin');

let paths = {
  source: {
    assets: {
      fonts: 'node_modules/font-awesome/fonts/',
      images: 'src/assets/images/'
    },
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
      { test: /\.html$/,
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
              attrs: ['img:data-src']
            }
          }
        ]
      },
      { test: /\.(png|svg|jpg|gif|ico)$/,
        loader: 'url-loader',
        options: {
          fallback: 'file-loader',
          name: '[name].[ext]',
          outputPath: 'assets/images/',
          // sets our base64 encoding threshold at 8KB
          limit: 8 * 1024
        }
      },
      { test: /\.(woff|woff2|eot|ttf|otf)$/,
        loader: 'file-loader'
      }
    ]
  },
  plugins: [
    new cleanWebpackPlugin(pathsToClean, { root: path.resolve(__dirname, '../public/') }),
    new copyWebpackPlugin([
      { from: paths.source.assets.fonts, to: paths.public.assets.fonts },
    ]),
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
