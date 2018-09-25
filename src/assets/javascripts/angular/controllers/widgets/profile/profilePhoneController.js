'use strict';

var _ = require('lodash');

/**
 * Profile Phone controller
 */
angular.module('calcentral.controllers').controller('ProfilePhoneController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    emptyObject: {
      type: {
        code: ''
      },
      number: '',
      countryCode: '',
      extension: '',
      primary: false
    },
    items: {
      content: [],
      editorEnabled: false
    },
    types: [],
    currentObject: {},
    isSaving: false,
    errorMessage: ''
  });
  $scope.contacts = {};

  var parsePerson = function(response) {
    apiService.profile.parseSection($scope, response, 'phones');
  };

  var parseTypes = function(response) {
    $scope.types = apiService.profile.filterTypes(_.get(response, 'data.feed.xlatvalues.values'), $scope.items);
  };

  var getPerson = profileFactory.getPerson;
  var getTypes = profileFactory.getTypesPhone;

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

  var actionCompleted = function(response) {
    apiService.profile.actionCompleted($scope, response, loadInformation);
  };

  var deleteCompleted = function(response) {
    $scope.isDeleting = false;
    actionCompleted(response);
  };

  $scope.delete = function(item) {
    return apiService.profile.delete($scope, profileFactory.deletePhone, {
      type: item.type.code
    }).then(deleteCompleted);
  };

  var saveCompleted = function(response) {
    $scope.isSaving = false;
    actionCompleted(response);
  };

  $scope.save = function(item) {
    apiService.profile.save($scope, profileFactory.postPhone, {
      type: item.type.code,
      phone: item.number,
      countryCode: item.countryCode,
      extension: item.extension,
      isPreferred: item.primary ? 'Y' : 'N'
    }).then(saveCompleted);
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
