/* jshint esversion:6 */
/* jshint strict:false */
/* jscs: disable  disallowSpacesInsideObjectBrackets */
/* jscs: disable  requirePaddingNewLinesInObjects */
/* jscs: disable  requireObjectKeysOnNewLine */
const convert = require('koa-connect');
const path = require('path');
const proxy = require('http-proxy-middleware');
const webpackMerge = require('webpack-merge');

const port = 3001;
const baseConfig = require('./base.config.js');

// These endpoints (from routes.rb) will return a response from localhost:3000
const railsApiRoutes = [
                        '/act_as',
                        '/advisor_act_as',
                        '/api',
                        '/auth',
                        '/basic_auth_login',
                        '/campus',
                        '/canvas',
                        '/clearing_house',
                        '/college_scheduler',
                        '/delegate_act_as',
                        '/delete_user',
                        '/delete_users',
                        '/higher_one',
                        '/logout',
                        '/reauth',
                        '/stop_act_as',
                        '/stop_advisor_act_as',
                        '/stop_delegate_act_as'
                      ];

module.exports = webpackMerge(baseConfig, {
  devtool: 'eval-source-map',
  mode: 'development',
  module: {
    rules: [{
        test: /\.scss$/,
        use: [{
          loader: 'style-loader'
        }, {
          loader: 'css-loader', options: {
            sourceMap: true
          }
        }, {
          loader: 'sass-loader', options: {
            sourceMap: true
          }
        }]
      }, {
        test: /\.css$/,
        use: [{
          loader: 'style-loader'
        }, {
          loader: 'css-loader', options: {
            sourceMap: true
          }
        }]
      }
    ]
  },
  serve: {
    add: (app, middleware, options) => {
      app.use(convert(proxy({
        context: railsApiRoutes,
        target: 'http://localhost:3000'
      })));
    },
    devMiddleware: {
      publicPath: path.resolve(__dirname, '../public/'),
      writeToDisk: (filePath) => {
        // excludes writing hot-module files created by webpack-serve to the disk
        return !/hot-update/.test(filePath);
      }
    },
    port: port
  }
});
