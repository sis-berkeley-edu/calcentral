'use strict';

var _ = require('lodash');

/**
 * Profile Address controller
 */
angular.module('calcentral.controllers').controller('ProfileAddressController', function(apiService, profileFactory, $scope) {
  var initialState = {
    countries: [],
    currentObject: {},
    emptyObject: {
      type: {
        code: ''
      },
      country: 'USA',
      fields: {}
    },
    errorMessage: '',
    isSaving: false,
    items: {
      content: [],
      editorEnabled: false
    },
    states: [],
    types: []
  };

  angular.extend($scope, initialState);
  var initialEdit = {
    state: '',
    load: false
  };
  var countryWatcher;

  var parsePerson = function(response) {
    apiService.profile.parseSection($scope, response, 'addresses');
    $scope.items.content = apiService.profile.fixFormattedAddresses($scope.items.content);
  };

  var parseTypes = function(response) {
    $scope.types = apiService.profile.filterTypes(_.get(response, 'data.feed.addressTypes'), $scope.items);
  };

  var parseCountries = function(response) {
    $scope.countries = _.sortBy(_.filter(_.get(response, 'data.feed.countries'), {
      hasAddressFields: true
    }), 'descr');
  };

  var parseAddressFields = function(response) {
    $scope.currentObject.fields = _.get(response, 'data.feed.labels');
  };

  var parseStates = function(response) {
    $scope.states = _.sortBy(_.get(response, 'data.feed.states'), 'descr');
    if ($scope.states && $scope.states.length) {
      angular.merge($scope.currentObject, {
        data: {
          state: initialEdit.state
        }
      });
      initialEdit.state = '';
    }
  };

  var removePreviousAddressData = function() {
    $scope.currentObject.data = _.fromPairs(_.map($scope.currentObject.data, function(value, key) {
      if (['country', 'type'].indexOf(key) === -1) {
        return [key, ''];
      } else {
        return [key, value];
      }
    }));
  };

  var countryWatch = function(countryCode) {
    if (!countryCode) {
      return;
    }
    if (!initialEdit.load) {
      removePreviousAddressData();
      apiService.profile.removeErrorMessage($scope);
    }
    $scope.currentObject.stateFieldLoading = true;
    initialEdit.load = false;
    // $scope.currentObject.data = {};
    // Get the different address fields / labels for the country
    profileFactory.getAddressFields({
      country: countryCode
    })
    .then(parseAddressFields)
    // Get the states for a certain country (if available)
    .then(function() {
      return profileFactory.getStates({
        country: countryCode
      });
    })
    .then(parseStates)
    .then(function() {
      $scope.currentObject.stateFieldLoading = false;
    });
  };

  var startCountryWatch = function() {
    countryWatcher = $scope.$watch('currentObject.data.country', countryWatch);
  };

  var getPerson = profileFactory.getPerson;
  var getTypes = profileFactory.getTypesAddress;
  var getCountries = profileFactory.getCountries;

  var loadInformation = function(options) {
    $scope.isLoading = true;

    // If we were previously watching, we need to remove that
    if (countryWatcher) {
      countryWatcher();
    }

    getPerson({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parsePerson)
    .then(getTypes)
    .then(parseTypes)
    .then(getCountries)
    .then(parseCountries)
    .then(startCountryWatch)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  var deleteCompleted = function(response) {
    $scope.isDeleting = false;
    apiService.profile.actionCompleted($scope, response, loadInformation);
  };

  $scope.delete = function(item) {
    return apiService.profile.delete($scope, profileFactory.deleteAddress, {
      type: item.type.code
    }).then(deleteCompleted);
  };

  var saveCompleted = function(response) {
    $scope.isSaving = false;
    apiService.profile.actionCompleted($scope, response, loadInformation);
  };

  var saveFailed = function(response) {
    $scope.isSaving = false;
    apiService.profile.actionFailed($scope, response, loadInformation);
  };

  $scope.save = function(item) {
    var merge = _.merge({
      addressType: item.type.code,
      country: item.country
    }, apiService.profile.matchFields($scope.currentObject.fields, item));

    apiService.profile
    .save($scope, profileFactory.postAddress, merge)
    .then(saveCompleted)
    .catch(saveFailed);
  };

  $scope.showAdd = function() {
    apiService.profile.showAdd($scope, $scope.emptyObject);
  };

  $scope.showEdit = function(item) {
    apiService.profile.showEdit($scope, item);
    $scope.currentObject.data.country = item.country;
    initialEdit.state = item.state || '';
    initialEdit.load = true;
  };

  $scope.closeEditor = function() {
    apiService.profile.closeEditor($scope);
  };

  loadInformation();
});
