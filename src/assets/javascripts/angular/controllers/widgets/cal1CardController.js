'use strict';

var angular = require('angular');

/**
 * Footer controller
 */
angular.module('calcentral.controllers').controller('Cal1CardController', function(cal1CardFactory, $scope) {
  var loadCal1Card = function() {
    cal1CardFactory.getCal1Card().then(
      function successCallback(response) {
        angular.extend($scope, response.data);
        $scope.isLoading = false;
      }
    );
  };

  loadCal1Card();
});
