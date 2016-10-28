'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('StudentResourcesController', function(studentResourcesFactory, userService, $scope) {
  $scope.isLoading = true;

  var backToText = 'My Dashboard';

  /**
   * Add the back to text (used for Campus Solutions) to the link
   */
  var addBackToTextLink = function(link) {
    link.backToText = backToText;
    return link;
  };

  /**
   * Add the back to text
   */
  var addBackToText = function(resources) {
    _.mapValues(resources, addBackToTextLink);
    return resources;
  };

  var loadStudentResources = function() {
    return studentResourcesFactory.getStudentResources();
  };

  var parseStudentResources = function(data) {
    var resources = _.get(data, 'data.feed.resources');
    if (!_.isEmpty(resources)) {
      $scope.studentResources = addBackToText(resources);
    }
  };

  var setStudentRole = function() {
    $scope.isLawStudent = userService.profile.roles.law;
    $scope.isGraduateStudent = userService.profile.roles.graduate;
    $scope.isUndergraduate = userService.profile.roles.undergrad;
  };

  var loadInformation = function() {
    loadStudentResources()
    .then(parseStudentResources)
    .then(setStudentRole)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
