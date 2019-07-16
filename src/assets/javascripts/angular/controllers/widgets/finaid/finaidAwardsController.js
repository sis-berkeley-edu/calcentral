'use strict';

var _ = require('lodash');

/**
 * Financial Aid - Awards controller
 */
angular.module('calcentral.controllers').controller('FinaidAwardsController', function($scope, finaidAwardsFactory, finaidService) {
  var keysGiftWork = ['giftaid', 'waiversAndOther', 'workstudy'];
  var keysLoans = ['subsidizedloans', 'unsubsidizedloans', 'alternativeloans', 'plusloans'];

  $scope.finaidAwardsInfo = {
    isLoading: true,
    keysGiftWork: keysGiftWork,
    keysLoans: keysLoans,
    errored: false,
    showDecimals: false
  };
  $scope.finaidAwards = {};

  var checkKeys = function(keys, object) {
    return _.some(keys, _.partial(_.get, object));
  };

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

    // Check whether this student has any awards at all
    // and see whether they have any loans
    var allKeys = keysGiftWork.concat(keysLoans);
    feed.hasAwards = checkKeys(allKeys, feed.awards);
    feed.hasLoans = checkKeys(keysLoans, feed.awards);

    feed = addColors(feed);

    return feed;
  };

  var checkForDisbursementDates = function(incoming) {
    const found = incoming.find((obj) => obj.disbursementDate);

    if (found) {
      return 'Est. Disbursement';
    } else {
      return 'Term';
    }
  };

  var formatCurrency = function(amount) {
    return $scope.finaidAwardsInfo.showDecimals ? amount.toFixed(2) : amount;
  };

  const notInteger = (value) => !Number.isInteger(value);

  var shouldShowDecimals = function({awards: {giftaid,
    waiversAndOther,
    workstudy,
    subsidizedloans,
    unsubsidizedloans,
    plusloans,
    alternativeloans}}) {
    const items = [giftaid,
      waiversAndOther,
      workstudy,
      subsidizedloans,
      unsubsidizedloans,
      plusloans,
      alternativeloans];

    return !!items.find(data => {
      const {
        total: {
          amount
        } = {},
        items
      } = data;

      if (notInteger(amount)) {
        return true;
      } else {
        return items.find(item => {
          const {
            leftColumn: {
              amount: leftAmount
            } = {},
            rightColumn: {
              amount: rightAmount
            } = {},
            subItems: {
              remainingAmount,
              termDetails = []
            } = {}
          } = item;

          const found = [
            leftAmount,
            rightAmount,
            remainingAmount
          ].find(notInteger);

          if (found) {
            return true;
          } else {
            const foundTerm = termDetails.find(term => notInteger(term.offered) || notInteger(term.disbursed));

            if (foundTerm) {
              return true;
            }
          }
        });
      }
    });
  };

  var loadAwards = function() {
    finaidAwardsFactory.getAwards({
      finaidYearId: finaidService.options.finaidYear.id
    }).then(function successCallback(response) {
      angular.extend($scope.finaidAwards, parseAwards(_.get(response, 'data')));
      $scope.finaidAwardsInfo.errored = _.get(response, 'data.errored');
      $scope.finaidAwardsInfo.showDecimals = shouldShowDecimals(_.get(response, 'data'));
    })
    .finally(function() {      
      $scope.finaidAwardsInfo.checkForDisbursementDates = checkForDisbursementDates;
      $scope.finaidAwardsInfo.formatCurrency = formatCurrency;
      $scope.finaidAwardsInfo.isLoading = false;
    });
  };

  var loadData = function() {
    loadAwards();
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadData);
});
