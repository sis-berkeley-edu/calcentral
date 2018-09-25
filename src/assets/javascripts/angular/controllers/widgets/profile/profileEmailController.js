'use strict';

var _ = require('lodash');

/**
 * Profile Email controller
 */
angular.module('calcentral.controllers').controller('ProfileEmailController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    currentObject: {},
    emptyObject: {
      type: {
        code: ''
      },
      emailAddress: '',
      primary: false
    },
    items: {
      content: [],
      editorEnabled: false
    },
    types: [],
    isSaving: false,
    errorMessage: ''
  });
  $scope.contacts = {};

  var parsePerson = function(response) {
    apiService.profile.parseSection($scope, response, 'emails');
  };

  var parseTypes = function(response) {
    $scope.types = apiService.profile.filterTypes(_.get(response, 'data.feed.xlatvalues.values'), $scope.items);
  };

  var getPerson = profileFactory.getPerson;
  var getTypes = profileFactory.getTypesEmail;

  var loadInformation = function(options) {
    $scope.isLoading = true;
    getPerson({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parsePerson)
    .then(getTypes)
    .then(parseTypes)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  var deleteCompleted = function(response) {
    $scope.isDeleting = false;
    apiService.profile.actionCompleted($scope, response, loadInformation);
  };

  $scope.delete = function(item) {
    return apiService.profile.delete($scope, profileFactory.deleteEmail, {
      type: item.type.code
    }).then(deleteCompleted);
  };

  var saveCompleted = function(response) {
    $scope.isSaving = false;
    apiService.profile.actionCompleted($scope, response, loadInformation);
  };

  var saveFailed = function(response) {
    $scope.isSaving = false;
    apiService.profile.actionFailed($scope, response);
  };

  $scope.save = function(item) {
    apiService.profile.save($scope, profileFactory.postEmail, {
      type: item.type.code,
      email: item.emailAddress,
      isPreferred: item.primary ? 'Y' : 'N'
    }).then(saveCompleted)
      .catch(saveFailed);
  };

  $scope.showAdd = function() {
    apiService.profile.showAdd($scope, $scope.emptyObject);
  };

  $scope.showEdit = function(item) {
    apiService.profile.showEdit($scope, item);
  };

  $scope.closeEditor = function() {
    apiService.profile.closeEditor($scope);
  };

  loadInformation();
});
