'use strict';

var _ = require('lodash');

angular.module('calcentral.services').service('profileService', function() {
  var actionFailed = function($scope, response) {
    $scope.errorMessage = _.get(response, 'data.feed.errmsgtext') || 'An error occurred while saving your data.';
  };

  var actionCompleted = function($scope, response, callback) {
    if (response.data.error || response.data.errored) {
      actionFailed();
    } else {
      $scope.closeEditor();
      callback({
        refresh: true
      });
    }
  };

  var closeEditors = function($scope) {
    angular.forEach($scope.items.content, function(item) {
      if (item && item.isModifying) {
        item.isModifying = false;
      }
    });
  };

  var closeEditor = function($scope) {
    closeEditors($scope);
    $scope.currentObject = {};
    $scope.items.editorEnabled = false;
  };

  /*
   * Filter out the different types (e.g. for phone / email / ...)
   *
   * We need to exclude the ones that
   *  - Already display on the page
   *  - Are display only
   *
   * Different type controls for the types:
   * D = Display Only
   * F = Full Edit
   * N = Do Not Display
   * U = Edit - No Delete
   */
  var filterTypes = function(values, items) {
    if (!values) {
      return [];
    }
    var currentTypes = _.map(items.content, 'type.code');
    return _.filter(values, function(value) {
      return currentTypes.indexOf(value.fieldvalue) === -1 && value.typeControl !== 'D';
    });
  };

  var findItem = function(items, code) {
    return _.find(items, function(item) {
      return item.type.code === code;
    });
  };

  var findPreferred = function(items) {
    return findItem(items, 'PRF');
  };

  var findPrimary = function(items) {
    return findItem(items, 'PRI');
  };

  var fixFormattedAddress = function(formattedAddress) {
    return formattedAddress.replace(/\\n/g, '\n');
  };

  var fixFormattedAddresses = function(addresses) {
    if (!addresses) {
      return;
    }
    return addresses.map(function(element) {
      var formattedAddress = _.get(element, 'formattedAddress');
      if (formattedAddress) {
        element.formattedAddress = formattedAddress.replace(/\\n/g, '\n');
      }
      return element;
    });
  };

  var deleteItem = function($scope, action, item) {
    $scope.isDeleting = true;
    return action(item);
  };

  /*
   * Map address fields to the current country and the ones (depending on country) that the user has entered
   */
  var matchFields = function(fields, item) {
    var fieldIds = _.map(fields, 'field');
    var returnObject = {};
    _.forEach(item, function(value, key) {
      if (_.includes(fieldIds, key)) {
        returnObject[key] = value || '';
      }
    });
    return returnObject;
  };

  var parseSection = function($scope, data, section) {
    var person = data.data.feed;
    angular.extend($scope, {
      items: {
        content: person[section]
      }
    });
  };

  var removeErrorMessage = function($scope) {
    $scope.errorMessage = '';
  };

  var save = function($scope, action, item) {
    $scope.errorMessage = '';
    $scope.isSaving = true;
    return action(item);
  };

  var showSaveAdd = function($scope, item, config) {
    closeEditors($scope);
    angular.merge($scope.currentObject, {
      data: item
    });
    angular.merge($scope.currentObject, config);
    item.isModifying = true;
    $scope.errorMessage = '';
    $scope.items.editorEnabled = true;
  };

  var showAdd = function($scope, item) {
    var initObject = angular.copy(item);
    if (_.get($scope, 'types[0].fieldvalue')) {
      angular.merge(initObject, {
        type: {
          // Select the first item in the dropdown
          code: _.get($scope, 'types[0].fieldvalue')
        }
      });
    }
    showSaveAdd($scope, initObject, {
      isAdding: true
    });
  };

  var showEdit = function($scope, item) {
    showSaveAdd($scope, item, {
      isPreferredOnLoad: !!item.primary
    });
  };

  // Expose methods
  return {
    actionFailed: actionFailed,
    actionCompleted: actionCompleted,
    closeEditor: closeEditor,
    delete: deleteItem,
    filterTypes: filterTypes,
    findPreferred: findPreferred,
    findPrimary: findPrimary,
    fixFormattedAddress: fixFormattedAddress,
    fixFormattedAddresses: fixFormattedAddresses,
    matchFields: matchFields,
    parseSection: parseSection,
    removeErrorMessage: removeErrorMessage,
    save: save,
    showAdd: showAdd,
    showEdit: showEdit
  };
});
