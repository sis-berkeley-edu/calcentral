'use strict';

var _ = require('lodash');

import 'icons/changed-orange.svg';
import 'icons/changed-white.svg';
import 'icons/compare.svg';
import 'icons/info.svg';
import 'icons/report.svg';
import shouldShowDecimals from './shouldShowDecimals';

/**
 * Financial Aid - Awards controller
 */
angular
  .module('calcentral.controllers')
  .controller('FinaidAwardsController', function(
    $scope,
    finaidAwardsFactory,
    finaidService,
    apiService
  ) {
    var keysGiftWork = ['giftaid', 'waiversAndOther', 'workstudy'];
    var keysLoans = [
      'subsidizedloans',
      'unsubsidizedloans',
      'alternativeloans',
      'plusloans',
    ];

    $scope.finaidAwardsInfo = {
      aidYear: null,
      isLoading: true,
      keysGiftWork: keysGiftWork,
      keysLoans: keysLoans,
      errored: false,
      showDecimals: false,
    };
    $scope.finaidAwards = {};
    $scope.canSeeFinAidSummaryLink = false;
    $scope.isDelegate = false;

    var addColors = function(feed) {
      _.mapValues(feed.awards, function(value, key) {
        if (value && _.includes(keysLoans, key)) {
          value.color = 'blue-dark';
        } else if (value && _.includes(keysGiftWork, key)) {
          value.color = 'blue-light';
        }
        return value;
      });

      return feed;
    };

    var parseAwards = function(feed) {
      if (!feed) {
        return;
      }

      feed = addColors(feed);

      return feed;
    };

    var checkForDisbursementDates = function(incoming) {
      const found = incoming.find(obj => obj.disbursementDate);

      if (found) {
        return 'Est. Disbursement';
      } else {
        return 'Term';
      }
    };

    var formatCurrency = function(amount) {
      return $scope.finaidAwardsInfo.showDecimals ? amount.toFixed(2) : amount;
    };

    var canSeeFinAidSummaryLink = function() {
      return (
        ($scope.finaidAwards.matriculated ||
          apiService.user.profile.roles.registered ||
          apiService.user.profile.roles.exStudent) &&
        (apiService.user.profile.academicRoles.current.ugrd ||
          apiService.user.profile.academicRoles.current.grad ||
          apiService.user.profile.academicRoles.current.law) &&
        !apiService.user.profile.academicRoles.current.summerVisitor
      );
    };

    var isDelegate = function() {
      return apiService.user.profile.delegateActingAsUid ? true : false;
    };

    var loadAwards = function() {
      finaidAwardsFactory
        .getAwards({
          finaidYearId: finaidService.options.finaidYear.id,
        })
        .then(function successCallback(response) {
          const data = _.get(response, 'data');
          const errored = _.get(response, 'data.errored');
          angular.extend($scope.finaidAwards, parseAwards(data));
          $scope.finaidAwardsInfo.errored = errored;
          $scope.finaidAwardsInfo.showDecimals = shouldShowDecimals(data);
          $scope.canSeeFinAidSummaryLink = canSeeFinAidSummaryLink();
          $scope.isDelegate = isDelegate();
        })
        .finally(function() {
          $scope.finaidAwardsInfo.checkForDisbursementDates = checkForDisbursementDates;
          $scope.finaidAwardsInfo.formatCurrency = formatCurrency;
          $scope.finaidAwardsInfo.isLoading = false;
          $scope.finaidAwardsInfo.aidYear = finaidService.options.finaidYear.id;
        });
    };

    var loadData = function() {
      loadAwards();
    };

    $scope.$on('calcentral.custom.api.finaid.finaidYear', loadData);
  });
