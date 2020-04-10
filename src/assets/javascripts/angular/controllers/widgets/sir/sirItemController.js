'use strict';

var _ = require('lodash');

/**
 * SIR (Statement of Intent to Register) item controller
 */
angular.module('calcentral.controllers').controller('SirItemController', function(apiService, sirFactory, $rootScope, $scope) {
  $scope.sirItem = {
    form: {
      option: false,
      decline: {},
      check: {}
    },
    isFormValid: false,
    isSubmitting: false,
    hasError: false,
    showErrorMessage: false,
  };

  var getResponseObject = function() {
    var option = $scope.sirItem.form.option;
    var admissionsManagement = $scope.item.checkListMgmtAdmp;

    var response = {
      acadCareer: admissionsManagement.acadCareer,
      studentCarNbr: admissionsManagement.stdntCarNbr,
      admApplNbr: admissionsManagement.admApplNbr,
      applProgNbr: admissionsManagement.applProgNbr,
      chklstItemCd: $scope.item.chklstItemCd,
      actionReason: option.progReason,
      progAction: option.progAction
    };

    // Send some extra params when someone is declining
    if (option.progAction === 'WAPP') {
      response.responseReason = $scope.sirItem.form.decline.reasonCode;
      response.responseDescription = $scope.sirItem.form.decline.reasonDescription;
    }

    return response;
  };

  $scope.setButtonClass = function() {
    if (
      (apiService.user.profile.actAsOptions.canPost &&
      $scope.sirItem.isFormValid &&
      !$scope.sirItem.isSubmitting) ||
      !$scope.sirItem.form.option
    ) {
      $scope.sirItem.showErrorMessage = false;
      return 'cc-button cc-button-blue';
    } else {
      return 'cc-button cc-button-grey';
    }
  };

  $scope.checkAndSubmit = function() {
    if ($scope.sirItem.isFormValid) {
      $scope.submitSirReponse();
    } else {
      $scope.sirItem.showErrorMessage = true;
    }
  };

  $scope.submitSirReponse = function() {
    $scope.sirItem.isSubmitting = true;

    var response = getResponseObject();
    return sirFactory.postSirResponse(response).then(function(postResponse) {
      // Check for errors
      if (_.get(postResponse, 'data.errored')) {
        $scope.sirItem.hasError = true;
        $scope.sirItem.isSubmitting = false;
      } else {
        // Reload the checklistItem you were currently modifying
        $rootScope.$broadcast('calcentral.custom.api.sir.update', {
          option: $scope.sirItem.form.option,
          response: response
        });
      }
    });
  };

  var isFormValid = function(form) {
    // Make sure we at least select one option
    if (!form.option) {
      return false;
    }

    // If 'yes' is selected, make sure we have all checkboxes as well
    if (form.option.progAction === 'DEIN') {
      if (!form.check) {
        return false;
      } else {
        return _.every($scope.item.config.sirConditions, function(element) {
          return $scope.sirItem.form.check[element.seqnum] &&
            $scope.sirItem.form.check[element.seqnum].valid;
        });
      }
    }
    $scope.sirItem.showErrorMessage = false;
    return true;
  };

  var validateForm = function() {
    $scope.$watch('sirItem.form', function(value) {
      if (!value) {
        return;
      }
      $scope.sirItem.isFormValid = isFormValid($scope.sirItem.form);
    }, true);
  };

  /*
   * Select the first response reason from the dropdown
   * This way we don't see an empty value on load
   */
  var selectFirstResponseReason = function() {
    $scope.$watch('item.responseReasons', function(value) {
      if (!_.get(value, 'length')) {
        return;
      }
      $scope.sirItem.form.decline.reasonCode = $scope.item.responseReasons[0].responseReason;
    });
  };

  var init = function() {
    selectFirstResponseReason();
    validateForm();
  };

  init();
});
