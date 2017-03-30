'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Admin controller
 */
angular.module('calcentral.controllers').controller('AdminController', function(adminFactory, adminService, apiService, $scope) {
  $scope.admin = {
    actAs: {
      id: ''
    },
    searchedUsers: [],
    storedUsers: {},
    isLoading: true
  };

  $scope.admin.storeSavedUser = function(user) {
    return adminFactory.storeUser({
      uid: adminService.getLdapUid(user)
    }).then(getStoredUsersUncached);
  };

  $scope.admin.deleteSavedUser = function(user) {
    return adminFactory.deleteUser({
      uid: adminService.getLdapUid(user)
    }).then(getStoredUsersUncached);
  };

  $scope.admin.deleteAllSavedUsers = function() {
    return adminFactory.deleteAllSavedUsers().then(getStoredUsersUncached);
  };

  $scope.admin.deleteAllRecentUsers = function() {
    return adminFactory.deleteAllRecentUsers().then(getStoredUsersUncached);
  };

  $scope.admin.updateIDField = function(id) {
    $scope.admin.actAs.id = parseInt(id, 10);
  };

  /**
   * Get stored recent/saved users
   */
  var getStoredUsers = function(options) {
    return adminFactory.getStoredUsers(options).then(
      function successCallback(response) {
        $scope.admin.storedUsers = _.get(response, 'data.users');
        updateUserLists();
        $scope.admin.isLoading = false;
      },
      function errorCallback() {
        $scope.admin.actAsErrorStatus = 'There was a problem fetching your items.';
        $scope.admin.isLoading = false;
      }
    );
  };

  var getStoredUsersUncached = function() {
    return getStoredUsers({
      refreshCache: true
    });
  };

  /**
   * Lookup user using either UID or SID
   */
  var lookupUser = function(id) {
    return adminFactory.userLookup({
      id: id
    }).then(handleLookupUserSuccess, handleLookupUserError);
  };

  var handleLookupUserSuccess = function(ajaxResponse) {
    var response = {};
    var lookupUsers = ajaxResponse.data.users;
    if (lookupUsers.length > 0) {
      response.users = lookupUsers;
    } else {
      response.error = 'That does not appear to be a valid UID or SID.';
    }
    return response;
  };

  var handleLookupUserError = function(ajaxResponse) {
    var response = {};
    var errorMessage = ajaxResponse.error || _.get(ajaxResponse, 'data.error');
    if (errorMessage) {
      response.error = errorMessage;
    } else if (ajaxResponse.status === 403) {
      response.error = 'You are not authorized to view the requested user data.';
    } else {
      response.error = 'There was a problem searching for that user.';
    }
    return response;
  };

  $scope.admin.lookupUser = function() {
    $scope.admin.lookupErrorStatus = '';
    $scope.admin.users = [];

    lookupUser($scope.admin.id + '').then(
      function(response) {
        if (response.error) {
          $scope.admin.lookupErrorStatus = response.error;
        } else {
          $scope.admin.users = response.users;
        }
      }
    );
  };

  $scope.admin.actAsUser = function(user) {
    $scope.admin.actAsErrorStatus = '';
    $scope.admin.userPool = [];

    if (adminService.getLdapUid(user)) {
      return adminService.actAs(user);
    }

    if (!$scope.admin.actAs || !$scope.admin.actAs.id) {
      return;
    }

    lookupUser($scope.admin.actAs.id + '').then(
      function(response) {
        if (response.error) {
          $scope.admin.actAsErrorStatus = response.error;
          return;
        }
        if (response.users > 1) {
          $scope.admin.actAsErrorStatus = 'More than one user was found. Which user did you want to act as?';
          $scope.admin.userPool = response.users;
          return;
        }
        return adminService.actAs(response.users[0]).error(
          function(response) {
            if (response.error) {
              $scope.admin.actAsErrorStatus = response.error;
            }
          }
        );
      }
    );
  };

  /**
   * Update display of user lists
   */
  var updateUserLists = function() {
    $scope.admin.userBlocks[0].users = $scope.admin.storedUsers.saved;
    $scope.admin.userBlocks[1].users = $scope.admin.storedUsers.recent;

    var lastUser = $scope.admin.storedUsers.recent[0];
    // Display the last acted as UID in the "View as" input box
    $scope.admin.actAs.id = parseInt(adminService.getLdapUid(lastUser), 10) || '';
  };

  /**
   * Initialize stored user arrays
   */
  $scope.admin.userBlocks = [
    {
      title: 'Saved Users',
      clearAllUsers: $scope.admin.deleteAllSavedUsers,
      clearUser: $scope.admin.deleteSavedUser
    },
    {
      title: 'Recent Users',
      clearAllUsers: $scope.admin.deleteAllRecentUsers,
      storeUser: $scope.admin.storeSavedUser
    }
  ];
  getStoredUsers();
});
