'use strict';



/**
 * The delegate user is sent to this page after creating a new CalNet account.
 */
angular.module('calcentral.controllers').controller('DelegateLandingController', function(apiService, $scope, $timeout) {
  apiService.util.setTitle('Preparing Account');

  // Give IDM a moment to create the delegate's CalNet account prior to CAS authentication prompt.
  var waitTimeMilliseconds = 5 * 1000;

  var init = function() {
    $timeout(function() {
      apiService.util.redirect('delegate_welcome');
    }, waitTimeMilliseconds);
  };

  init();
});
