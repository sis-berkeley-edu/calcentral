'use strict';

var angular = require('angular');

/**
 * My Groups controller
 */
angular.module('calcentral.controllers').controller('MyGroupsController', function(apiService, myGroupsFactory, $routeParams, $scope) {
  var getMyGroups = function(options) {
    myGroupsFactory.getGroups(options).then(
      function successCallback(response) {
        apiService.updatedFeeds.feedLoaded(response.data);
        angular.extend($scope, response.data);
      }
    );
  };

  $scope.$on('calcentral.api.updatedFeeds.updateServices', function(event, services) {
    if (services && services['MyGroups::Merged']) {
      getMyGroups({
        refreshCache: true
      });
    }
  });
  getMyGroups();
});
