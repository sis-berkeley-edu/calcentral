'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').service('profileService', function() {
  /**
   * Fired after an action (delete / save) has been completed
   */
  var actionCompleted = function($scope, response, callback) {
    if (response.data.errored) {
      $scope.errorMessage = _.get(response, 'data.feed.errmsgtext') || 'An error occurred while saving your data.';
    } else {
      $scope.closeEditor();
      callback({
        refresh: true
      });
    }
  };

  /**
   * Close the editors for a specific section (e.g. phone / email)
   */
  var closeEditors = function($scope) {
    angular.forEach($scope.items.content, function(item) {
      if (item && item.isModifying) {
        item.isModifying = false;
      }
    });
  };

  /**
   * Close the editor for a specific item in a section
   */
  var closeEditor = function($scope) {
    closeEditors($scope);
    $scope.currentObject = {};
    $scope.items.editorEnabled = false;
  };

  /**
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

  /**
   * Find a certain item with a specific code
   */
  var findItem = function(items, code) {
    return _.find(items, function(item) {
      return item.type.code === code;
    });
  };

  /**
   * Find a preferred item
   */
  var findPreferred = function(items) {
    return findItem(items, 'PRF');
  };

  /**
   * Find a primary item
   */
  var findPrimary = function(items) {
    return findItem(items, 'PRI');
  };

  /**
   * Process a single formattedAddress by replacing '\\n' with '\n'.
   */
  var fixFormattedAddress = function(formattedAddress) {
    return formattedAddress.replace(/\\n/g, '\n');
  };

  /**
   * Process an array of formattedAddresses by replacing '\\n' with '\n'.
   */
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

  /**
   * Delete a certain item in a section
   */
  var deleteItem = function($scope, action, item) {
    $scope.isDeleting = true;
    return action(item);
  };

  /**
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

  /**
   * Parse a certain section in the profile
   */
  var parseSection = function($scope, data, section) {
    var person = data.data.feed.student;
    angular.extend($scope, {
      items: {
        content: person[section]
      }
    });
  };

  /**
   * Removes the current error message
   */
  var removeErrorMessage = function($scope) {
    $scope.errorMessage = '';
  };

  /**
   * Save a certain item in a section
   */
  var save = function($scope, action, item) {
    $scope.errorMessage = '';
    $scope.isSaving = true;
    return action(item);
  };

  /**
   * Show the editor to add / edit object
   */
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

  /**
   * Show the add editor
   */
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

  /**
   * Show the edit editor
   */
  var showEdit = function($scope, item) {
    showSaveAdd($scope, item, {
      isPreferredOnLoad: !!item.primary
    });
  };

  // Expose methods
  return {
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
