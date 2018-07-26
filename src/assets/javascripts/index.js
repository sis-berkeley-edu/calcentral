/* jshint esversion:6 */
require('lodash');
require('moment');
require('js-natural-sort');
require('raven-js');
require('pikaday');
require('angular');
require('angular-route');
require('angular-sanitize');
// require('bulk-require')(__dirname, ['./**/*.js']);

// Styles
import '../stylesheets/lib/foundation.css';
import '../stylesheets/calcentral.scss';
import '../stylesheets/colors.scss';

// CalCentral JS
require('require-all')(__dirname + '/angular');
require('require-all')(__dirname + '/angularlib');
