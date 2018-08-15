'use strict';

var _ = require('lodash');

/**
 * Preferred Name Controller
 */
angular.module('calcentral.controllers').controller('BasicPreferredNameController', function(apiService, profileFactory, $scope, $rootScope) {
  angular.extend($scope, {
    emptyObject: {},
    items: {
      content: [],
      editorEnabled: false
    },
    types: [],
    currentObject: {},
    isSaving: false,
    errorMessage: '',
    preferredNamePattern: /^[\s]*([A-Za-z]+([\s\-]?[A-Za-z]+)*)[\s]*$/,
    primary: {}
  });

  var parsePerson = function(data) {
    var person = data.data.feed.student;
    var preferredName = apiService.profile.findPreferred(person.names);
    $scope.primary = apiService.profile.findPrimary(person.names);
    angular.extend($scope, {
      items: {
        content: [preferredName]
      }
    });
  };

  var getPerson = profileFactory.getPerson;

  var loadInformation = function(options) {
    $scope.isLoading = true;
    getPerson({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parsePerson)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  var actionCompleted = function(response) {
    apiService.profile.actionCompleted($scope, response, loadInformation);
  };

  var saveCompleted = function(response) {
    // Notify other controllers about the preferredName update.
    $rootScope.$broadcast('calcentral.custom.api.preferredname.update');

    $scope.isSaving = false;
    actionCompleted(response);
  };

  $scope.save = function(item) {
    apiService.profile.save($scope, profileFactory.postName, {
      firstName: item.givenName,
      middleName: item.middleName,
      lastName: item.familyName,
      suffix: item.suffixName
    }).then(saveCompleted);
  };

  $scope.showAdd = function() {
    apiService.profile.showAdd($scope, {
      givenName: $scope.primary.givenName,
      middleName: $scope.primary.middleName,
      familyName: $scope.primary.familyName,
      suffixName: $scope.primary.suffixName
    });
  };

  $scope.showEdit = function(item) {
    apiService.profile.showEdit($scope, item);
  };

  $scope.closeEditor = function() {
    apiService.profile.closeEditor($scope);
  };

  loadInformation();
});
