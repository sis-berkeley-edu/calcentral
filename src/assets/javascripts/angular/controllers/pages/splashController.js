'use strict';

const SplashController = function(apiService) {
  apiService.util.setTitle('Home');
};

angular
  .module('calcentral.controllers')
  .controller('SplashController', SplashController);
