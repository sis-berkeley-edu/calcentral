'use strict';

// Angular
require('angular');
require('angular-route');
require('angular-sanitize');

// Node
require('lodash');
require('js-natural-sort');
require('raven-js');
require('pikaday');

// CalCentral JS - Initialization
require('./angular/calcentral.js');

// CalCentral JS - Configuration
let configuration = require.context('./angular/configuration', true, /\.js$/);
configuration.keys().forEach(configuration);

// CalCentral JS - Directives
let directives = require.context('./angular/directives', true, /\.js$/);
directives.keys().forEach(directives);

// CalCentral JS - Factories
let factories = require.context('./angular/factories', true, /\.js$/);
factories.keys().forEach(factories);

// CalCentral JS - Filters
let filters = require.context('./angular/filters', true, /\.js$/);
filters.keys().forEach(filters);

// CalCentral JS - Services
let services = require.context('./angular/services', true, /\.js$/);
services.keys().forEach(services);

// CalCentral JS - Controllers
let controllers = require.context('./angular/controllers', true, /\.js$/);
controllers.keys().forEach(controllers);
require('./angular/controllers/calcentralController.js');

// CalCentral Templates
const templates = require.context('../templates', true, /\.html$/);
templates.keys().forEach(templates);

// Images
const images = require.context('../images', true, /\.(png|svg|jpg|gif|ico)$/);
images.keys().forEach(images);

// Styles
require('../stylesheets/lib/foundation.css');
require('../stylesheets/calcentral.scss');
require('../stylesheets/colors.scss');
require('../../../node_modules/font-awesome/scss/font-awesome.scss');
