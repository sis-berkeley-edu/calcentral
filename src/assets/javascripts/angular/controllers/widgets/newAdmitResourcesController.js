'use strict';


var _ = require('lodash');

angular.module('calcentral.controllers').controller('NewAdmitResourcesController', function($scope, newAdmitResourcesFactory) {
  $scope.newAdmitResources = {
    admissionsSection: {},
    isLoading: true,
    pathwaysSection: {
      visible: false
    }
  };

  var parseNewAdmitResources = function(response) {
    var newAdmitResources = _.get(response, 'data');
    _.merge($scope.newAdmitResources, newAdmitResources);
    $scope.newAdmitResources.pathwaysSection.visible = !_.isEmpty(_.get(newAdmitResources, 'links.firstYearPathways'));
    $scope.newAdmitResources.isLoading = false;
  };

  var getNewAdmitResources = function() {
    return newAdmitResourcesFactory.getNewAdmitResources().then(parseNewAdmitResources);
  };

  getNewAdmitResources();
});
