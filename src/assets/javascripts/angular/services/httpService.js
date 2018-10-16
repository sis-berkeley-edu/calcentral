'use strict';

var _ = require('lodash');

angular.module('calcentral.services').factory('httpService', function($cacheFactory, $http) {
  /**
   * Clear the cache for a specific URL
   * @param {Object} options list of options that are being passed through
   * @param {String} url URL where the cache needs to be cleared
   * @return {undefined}
   */
  var clearCache = function(options, url) {
    if (options && options.refreshCache) {
      $cacheFactory.get('$http').remove(url);
    }
  };

  var encode = function(uri) {
    var unencodable = ['~', '!', '*', '(', ')', '\'', '.'];
    var cleanedUri = _.reject(uri, function(char) {
      return _.includes(unencodable, char);
    }).join('');
    return encodeURIComponent(cleanedUri);
  };

  /**
   * Request an endpoint
   * @param {Object} options list of options that are being passed through
   * @param {String} url URL where the cache needs to be cleared
   * @return {Object} response object
   */
  var request = function(options, url) {
    url = url ? url : options.url;
    clearCache(options, url);
    return $http.get(url, {
      cache: true,
      params: options ? options.params : null
    });
  };

  return {
    clearCache: clearCache,
    encode: encode,
    request: request
  };
});
