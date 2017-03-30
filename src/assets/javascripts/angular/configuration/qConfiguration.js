'use strict';

var angular = require('angular');

/**
 * Configure $qProvider to suppress errors on unhandled promise rejections
 */
angular.module('calcentral.config').config(function($qProvider) {
  $qProvider.errorOnUnhandledRejections(false);
});
