'use strict';



/**
 * My Groups controller
 */
angular.module('calcentral.controllers').controller('MyGroupsController', function(apiService, myGroupsFactory, $routeParams, $scope) {
  var getMyGroups = function(options) {
    myGroupsFactory.getGroups(options).then(
      function successCallback(response) {
        angular.extend($scope, response.data);
      }
    );
  };

  getMyGroups();
});
