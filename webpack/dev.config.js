'use strict';

const chokidar = require('chokidar');
const convert = require('koa-connect');
const path = require('path');
const proxy = require('http-proxy-middleware');
const stringify = require('json-stringify-safe');
const webpackMerge = require('webpack-merge');
const webSocket = require('ws');

const port = process.env.PORT || 3001;
const apiHost = process.env.API_HOST || 'http://localhost:3000';
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
            attrs: ['img:data-src']
          }
        }
      ]
    }]
  },
  serve: {
    add: (app) => {
      app.use(convert(proxy({
        context: railsApiRoutes,
        target: apiHost
      })));
    },
    devMiddleware: {
      writeToDisk: (filePath) => {
        // excludes writing hot-module files created by webpack-serve to the disk
        return !/hot-update/.test(filePath);
      }
    },
    hotClient: {
      host: 'localhost',
      port: 8090
    },
    on: {
      listening() {
        const socket = new webSocket('ws://localhost:8090');
        const watchPath = path.resolve(__dirname, '../src');
        const watchOptions = {
          awaitWriteFinish: {
            stabilityThreshold: 1500
          }
        };
        const watcher = chokidar.watch(watchPath, watchOptions);
        const reloadObject = {
          type: 'broadcast',
          data: {
            type: 'window-reload',
            data: {}
          }
        };

        watcher.on('change', () => {
          socket.send(stringify(reloadObject));
        });

        socket.on('close', () => {
          watcher.close();
        });
      }
    },
    port: port
  }
});
