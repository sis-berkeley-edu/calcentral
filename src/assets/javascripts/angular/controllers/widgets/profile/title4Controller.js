'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('Title4Controller', function(finaidFactory, title4Factory, $rootScope, $scope) {
  $scope.title4 = {
    isLoading: true,
    showMessage: false
  };

  var sendEvent = function() {
    $rootScope.$broadcast('calcentral.custom.api.finaid.approvals');
  };

  $scope.sendResponseT4 = function(response) {
    $scope.title4.isLoading = true;
    $scope.title4.showMessage = false;
    finaidFactory.postT4Response(response).then(sendEvent);
  };

  var getTitle4 = function(options) {
    return title4Factory.getTitle4(options).then(
      function successCallback(response) {
        var title4 = _.get(response, 'data.title4');
        $scope.title4 = title4;
        $scope.title4.isLoading = false;
      }
    );
  };

  getTitle4();

  $scope.$on('calcentral.custom.api.finaid.approvals', function() {
    getTitle4({
      refreshCache: true
    });
  });
});
