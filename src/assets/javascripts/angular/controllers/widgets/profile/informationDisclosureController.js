'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Controller for Information Disclosure, requests a deeplink URL for students
 * to manage any FERPA restrictions.
 */
angular.module('calcentral.controllers').controller('InformationDisclosureController', function(ferpaDeeplinkFactory, $scope) {
  $scope.ferpa = {
    deeplink: {},
    isErrored: false,
    isLoading: true
  };

  var loadInformation = function() {
    ferpaDeeplinkFactory.getUrl().then(function(data) {
      $scope.ferpa.isErrored = _.get(data, 'data.errored');
      $scope.ferpa.deeplink = _.get(data, 'data.feed.ucSrFerpa.ferpaDeeplink');

      // Notify spinner that display is ready
      $scope.ferpa.isLoading = false;
    });
  };

  loadInformation();
});
