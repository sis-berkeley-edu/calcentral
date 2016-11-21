'use strict';

var angular = require('angular');

angular.module('calcentral.controllers').controller('BillingDetailsController', function(apiService) {
  apiService.util.setTitle('My Finances');
});
