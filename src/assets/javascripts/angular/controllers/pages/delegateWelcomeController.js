'use strict';

/**
 * Welcome newly assigned delegates
 */
angular.module('calcentral.controllers').controller('DelegateWelcomeController', function(apiService) {
  apiService.util.setTitle('Welcome');
});
