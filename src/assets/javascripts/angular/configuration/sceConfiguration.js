'use strict';

var angular = require('angular');

/**
 * Set the SCE configuration for CalCentral
 */
angular.module('calcentral.config').config(function($sceDelegateProvider) {
  $sceDelegateProvider.resourceUrlWhitelist([
    'self',
    // Youtube
    'http://www.youtube.com/**',
    'https://www.youtube.com/**'
  ]);
});
