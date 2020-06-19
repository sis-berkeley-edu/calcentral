const path = require('path');
const webpack = require('webpack');
const webpackMerge = require('webpack-merge');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');

const {
  babelLoaderRule,
  imageLoaderRule,
  fontLoaderRule,
  cssModuleLoaderRuleForMode,
  // scssModuleLoaderRuleForMode,
  scssLoaderRuleForMode,
  cssLoaderRuleForMode,
  templateLoaderRule,
} = require('./webpack/loaders');

const apiHost = process.env.API_HOST || 'http://localhost:3000';
const port = process.env.PORT || 8080;

const apiRoutes = [
  '/act_as',
  '/advisor_act_as',
  '/api',
  '/assets',
  '/auth',
  '/basic_auth_login',
  '/canvas',
  '/ccadmin',
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
  '/stop_delegate_act_as',
];

const config = {
  devServer: {
    contentBase: path.resolve(__dirname, './dist'),
    historyApiFallback: true,
    port: port,
    proxy: {
      context: (pathname, req) => {
        if (req.headers.accept.indexOf('application/json') !== -1) {
          return true;
        } else {
          return apiRoutes.find(routeString =>
            pathname.match(`^${routeString}`)
          );
        }
      },
      secure: false,
      target: apiHost,
    },
  },

  module: {
    rules: [
      babelLoaderRule,
      imageLoaderRule,
      fontLoaderRule,
      templateLoaderRule,
    ],
  },

  optimization: {
    minimize: true,
    minimizer: [new OptimizeCSSAssetsPlugin(), new TerserPlugin()],
    splitChunks: {
      chunks: 'all',
    },
  },

  plugins: [
    new webpack.IgnorePlugin(/moment/),
    new CleanWebpackPlugin({
      cleanOnceBeforeBuildPatterns: [
        'index.html',
        '*.css',
        '*.js',
        '*.LICENSE',
        'assets/**/*',
      ],
    }),
    new HtmlWebpackPlugin({
      filename: `index.html`,
      template: `src/index.html`,
    }),
  ],

  resolve: {
    modules: ['node_modules', path.resolve(__dirname, './src')],
    alias: {
      React: path.resolve(__dirname, './src/react'),
      Redux: path.resolve(__dirname, './src/redux'),
    },
  },
};

module.exports = (_env, argv) => {
  const mode = argv.mode || `production`;
  const isProduction = mode === `production`;

  const outputPath = isProduction
    ? path.resolve(__dirname, './public/')
    : path.resolve(__dirname, './dist');

  return webpackMerge(config, {
    mode: mode,
    module: {
      rules: [
        cssModuleLoaderRuleForMode(mode),
        scssLoaderRuleForMode(mode),
        cssLoaderRuleForMode(mode),
        // scssModuleLoaderRuleForMode(mode),
      ],
    },
    output: {
      filename: isProduction ? `[name].[chunkhash].js` : `[name].js`,
      path: outputPath,
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename:
          mode === `production` ? `[name].[chunkhash].css` : `[name].css`,
      }),
    ],
  });
};
