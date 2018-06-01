'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * My Up Next controller
 */
angular.module('calcentral.controllers').controller('UpNextController', function(apiService, upNextFactory, $scope) {
  var getUpNext = function(options) {
    upNextFactory.getUpNext(options).then(
      function successCallback(response) {
        if (!_.get(response, 'data.items')) {
          return;
        }
        angular.extend($scope, response.data);
      }
    );
  };

  getUpNext();
});
