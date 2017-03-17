'use strict';

var angular = require('angular');

/**
 * Footer controller
 */
angular.module('calcentral.controllers').controller('FooterController', function(serverInfoFactory, $scope) {
  $scope.footer = {
    showInfo: false
  };

  var loadServerInformation = function() {
    serverInfoFactory.getServerInfo().then(
      function successCallback(response) {
        angular.extend($scope, response.data);
      }
    );
  };

  $scope.$watch('footer.showInfo', function(showInfo) {
    if (showInfo && !$scope.versions) {
      loadServerInformation();
    }
  });
});
