'use strict';

var angular = require('angular');

/**
 * Campus controller
 */
angular.module('calcentral.controllers').controller('CampusController', function(apiService, campusLinksFactory, $routeParams, $scope) {
  var setPageTitle = function(topCategory) {
    apiService.util.setTitle('Campus - ' + topCategory);
  };

  var handleLinks = function(data) {
    if (data && data.currentTopCategory) {
      setPageTitle(data.currentTopCategory);
      angular.extend($scope, data);
    }
  };

  var getLinks = function() {
    return campusLinksFactory.getLinks({
      category: $routeParams.category
    });
  };

  var initialize = function() {
    getLinks()
      .then(handleLinks);
  };

  initialize();
});
