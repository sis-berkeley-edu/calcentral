'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * SIR (Statement of Intent to Register) controller
 *
 * Different item statuses
 *   C - Completed
 *   I - Initiated
 *   R - Received
 */
angular.module('calcentral.controllers').controller('SirController', function(sirFactory, $scope) {
  $scope.sir = {
    statuses: []
  };

  /**
   * Check whether 2 checklist items match on the admissions key
   */
  var checklistMatches = function(sirStatusItem, studentResponse) {
    return (sirStatusItem.checkListMgmtAdmp.acadCareer === studentResponse.response.acadCareer &&
            sirStatusItem.checkListMgmtAdmp.stdntCarNbr === studentResponse.response.studentCarNbr &&
            sirStatusItem.checkListMgmtAdmp.admApplNbr === studentResponse.response.admApplNbr &&
            sirStatusItem.checkListMgmtAdmp.applProgNbr === studentResponse.response.applProgNbr);
  };

  /**
  * Non-undergraduates:  Filters out any checklist item that is already "Completed" that the user has already seen
  * Undergraduates:  Filters out any checklist item that is "Completed" and has passed the functionally-defined expiration date in YML config
  */
  var parseSirStatuses = function(sirStatusesResponse, studentResponse) {
    var sirStatuses = _.get(sirStatusesResponse, 'data.sirStatuses');
    if ((!sirStatuses || !sirStatuses.length) && !studentResponse) {
      return;
    } else {
      updateScopeSirStatuses(sirStatuses, studentResponse);
    }
  };

  /**
   * Update the sir status items that need to be updated
   * We should only update the items that already are in the current scope & have an updated status.
   */
  var updateScopeSirStatuses = function(sirStatuses, studentResponse) {
    // If we don't have any checklist items yet, update the scope
    if (!$scope.sir.statuses.length) {
      $scope.sir.statuses = sirStatuses;
      return;
    } else {
      // Otherwise, find the matching item already in scope, and update it
      sirStatuses.forEach(function(sirStatusItem) {
        var result = _.find($scope.sir.statuses, {
          chklstItemCd: sirStatusItem.chklstItemCd,
          checkListMgmtAdmp: sirStatusItem.checkListMgmtAdmp
        });
        // If we don't find it in the current scope, it's a new item, so we should add it
        if (!result) {
          $scope.sir.statuses.push(sirStatusItem);
        } else {
          if (result.itemStatusCode !== sirStatusItem.itemStatusCode) {
            // Update specific checklist item
            var index = _.indexOf($scope.sir.statuses, result);
            $scope.sir.statuses.splice(index, 1, sirStatusItem);
          }
        }
      });
    }

    // Iterate through scoped sirs, and attach the student response to the relevant item
    if (studentResponse) {
      $scope.sir.statuses.forEach(function(scopeSirStatusItem) {
        if (checklistMatches(scopeSirStatusItem, studentResponse)) {
          scopeSirStatusItem.studentResponse = studentResponse;
        }
      });
    }
  };

  var getSirStatuses = function(options) {
    return sirFactory.getSirStatuses({
      refreshCache: _.get(options, 'refresh')
    });
  };

  var initWorkflow = function(options) {
    getSirStatuses(options)
      .then(function(sirStatusesResponse) {
        return parseSirStatuses(sirStatusesResponse, _.get(options, 'studentResponse'));
      });
  };

  initWorkflow();

  $scope.isReceivedUndergraduateNoDeposit = function(item) {
    return _.get(item, 'itemStatusCode') === 'R' && !_.get(item, 'deposit.required') && _.get(item, 'isUndergraduate');
  };

  $scope.isCompletedNonUndergraduate = function(item) {
    return _.get(item, 'itemStatusCode') === 'C' && !_.get(item, 'isUndergraduate');
  };

  $scope.$on('calcentral.custom.api.sir.update', function(event, studentResponse) {
    initWorkflow({
      refresh: true,
      studentResponse: studentResponse
    });
  });
});
