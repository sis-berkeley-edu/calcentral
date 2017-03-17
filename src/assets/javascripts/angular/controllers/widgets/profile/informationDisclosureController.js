'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Controller for Information Disclosure, requests a deeplink URL for students
 * to manage any FERPA restrictions.
 */
angular.module('calcentral.controllers').controller('InformationDisclosureController', function(csLinkFactory, $scope) {
  $scope.ferpa = {
    deeplink: {},
    isErrored: false,
    isLoading: true
  };

  var stopSpinner = function() {
    $scope.ferpa.isLoading = false;
  };

  var getFerpaRestrictionManagementLink = function() {
    csLinkFactory.getLink({
      urlId: 'UC_CX_STDNT_FERPA_RESTR_MGMT'
    }).then(
      function successCallback(response) {
        $scope.ferpa.deeplink = _.get(response, 'data.link');
        stopSpinner();
      }, function errorCallback() {
        $scope.ferpa.isErrored = true;
        $scope.ferpa.deeplink = null;
        stopSpinner();
      }
    );
  };

  getFerpaRestrictionManagementLink();
});
