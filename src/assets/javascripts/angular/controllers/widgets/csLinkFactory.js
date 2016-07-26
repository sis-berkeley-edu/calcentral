'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * CS Link Factory, retrieves links from Campus Solutions.
 */
angular.module('calcentral.factories').factory('csLinkFactory', function(apiService) {
  var csLinkUrl = '/api/campus_solutions/link';
  var getLink = function(options) {
    csLinkUrl += '?urlId=' + options.urlId;
    _.forEach(options.placeholders, function(value, key) {
      csLinkUrl += '&placeholders[' + key + ']=' + value;
    });
    return apiService.http.request(options, csLinkUrl);
  };
  return {
    getLink: getLink
  };
});
