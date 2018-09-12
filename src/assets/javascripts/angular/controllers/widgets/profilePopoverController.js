'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('ProfilePopoverController', function(csLinkFactory, $scope) {
  $scope.profilePopover = {
    isLoading: true
  };

  var loadLink = function() {
    csLinkFactory.getLink({
      urlId: 'UC_CC_PROFILE'
    }).then(function(response) {
      $scope.profilePopover.link = _.get(response, 'data.link');
      $scope.profilePopover.isLoading = false;
    });
  };

  loadLink();
});
