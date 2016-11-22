'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('BillingController', function(apiService, financesFactory, $filter, $scope) {
  $scope.activityIncrement = 50;
  $scope.activityLimit = 100;
  $scope.billing = {
    data: {},
    hasCarsActivity: false,
    isErrored: false,
    isLoading: true,
    isLoadingCars: true,
    sort: {
      column: 'itemEffectiveDate',
      descending: true
    }
  };
  $scope.filter = {
    choice: 'balance',
    choices: [{
      value: 'balance',
      label: 'Balance'
    }, {
      value: 'transactions',
      label: 'All Transactions'
    }, {
      value: 'daterange',
      label: 'Date Range'
    }, {
      value: 'term',
      label: 'Term'
    }],
    addedTerms: [],
    terms: [{
      // ngRepeat will clear the filter if the value is undefined, so 'itemTermId' is not set here
      itemTermDescription: 'All'
    }],
    searchDates: {
      startDt: '',
      endDt: ''
    },
    parsedDates: {
      startDt: '',
      endDt: ''
    },
    searchTermId: {},
    searchStatus: 0,
    statuses: {
      balance: 0,
      allTransactions: ['Unpaid', 'Paid']
    }
  };
  $scope.search = {};

  var getTermOptions = function(billingItem) {
    if (!_.includes($scope.filter.addedTerms, billingItem.itemTermId)) {
      $scope.filter.addedTerms.push(billingItem.itemTermId);
      $scope.filter.terms.push({
        itemTermDescription: billingItem.itemTermDescription,
        itemTermId: billingItem.itemTermId
      });
    }
  };

  var hasCarsActivity = function(data) {
    $scope.billing.hasCarsActivity = !!_.get(data, 'data.activity.length');
  };

  var loadCarsInfo = function() {
    financesFactory.getFinances()
      .then(hasCarsActivity)
      .finally(function() {
        $scope.billing.isLoadingCars = false;
      });
  };

  /**
   * Adds a searchable date format property to the billing object
   */
  var makeDatesSearchable = function(billingItem) {
    if (billingItem.itemEffectiveDate) {
      var itemEffectiveDateSearch = $filter('date')(billingItem.itemEffectiveDate, 'MM/dd/yy');
      _.set(billingItem, 'itemEffectiveDateSearch', itemEffectiveDateSearch);
    }
    if (billingItem.itemDueDate) {
      var itemDueDateSearch = $filter('date')(billingItem.itemDueDate, 'MM/dd/yy');
      _.set(billingItem, 'itemDueDateSearch', itemDueDateSearch);
    }
  };

  var makeDollarAmountsSearchable = function(billingItem) {
    if (billingItem.itemLineAmount) {
      var itemLineAmountSearch = '$' + billingItem.itemLineAmount.toFixed(2);
      _.set(billingItem, 'itemLineAmountSearch', itemLineAmountSearch);
    }
    if (billingItem.itemBalance) {
      var itemBalanceSearch = '$' + billingItem.itemBalance.toFixed(2);
      _.set(billingItem, 'itemBalanceSearch', itemBalanceSearch);
    }
  };

  var setAmountStrings = function(billingItem) {
    _.forOwn(billingItem, function(value, key) {
      if (_.isNumber(value)) {
        _.set(billingItem, key + 'String', value.toFixed(2));
      }
    });
    return billingItem;
  };

  var parseBillingInfo = function(data) {
    var billing = _.get(data, 'data.feed');

    if (!billing || !billing.summary) {
      $scope.billing.isErrored = true;
      return;
    }

    billing.summary = setAmountStrings(billing.summary);

    // Suppress all billing items with itemLineAmount: 0 and itemLineBalance: 0.
    billing.activity = _.reject(billing.activity, {
      itemLineAmount: 0,
      itemBalance: 0
    });

    billing.activity = _.map(billing.activity, function(object) {
      var billingItem = _.mapValues(object, function(value) {
        value = parseIncomingDates(value);
        return value;
      });
      return billingItem;
    });

    _.forEach(billing.activity, function(billingItem) {
      getTermOptions(billingItem);
      makeDatesSearchable(billingItem);
      makeDollarAmountsSearchable(billingItem);
      setAmountStrings(billingItem);
      if (billingItem.itemType && billingItem.itemType === 'W') {
        billingItem.itemType = 'Adjustment';
      }
    });

    $scope.billing.data = billing;
  };

  var parseIncomingDates = function(value) {
    var regex = /^(\d{4})[\-](0?[1-9]|1[012])[\-](0?[1-9]|[12][0-9]|3[01])$/;
    var item = value + '';
    var match = item.match(regex);
    if (match && match[0]) {
      var parsedDate = new Date(match[1], parseInt(match[2], 10) - 1, match[3]);
      return parsedDate;
    }
    return value;
  };

  var resetSearch = function() {
    $scope.filter.searchTermId = {};
    $scope.filter.searchDates.startDt = '';
    $scope.filter.searchDates.endDt = '';
    $scope.filter.parsedDates.startDt = '';
    $scope.filter.parsedDates.endDt = '';
    $scope.filter.searchStatus = '';
  };

  var selectDefaultTerm = function(billingSummary) {
    var currentTermId = billingSummary.currentTermId;
    // When the current term actually exists in the activity list, we select it
    // Otherwise, we select the first item in the list
    if (_.includes($scope.filter.addedTerms, currentTermId)) {
      $scope.filter.searchTermId.itemTermId = currentTermId;
    } else {
      $scope.filter.searchTermId.itemTermId = $scope.filter.addedTerms[0];
    }
  };

  var loadBillingInfo = function() {
    financesFactory.getCsFinances()
      .then(parseBillingInfo)
      .then(loadCarsInfo)
      .finally(function() {
        $scope.billing.isLoading = false;
      });
  };

  $scope.changeSorting = function(column) {
    if (_.isEqual($scope.billing.sort.column, column)) {
      $scope.billing.sort.descending = !$scope.billing.sort.descending;
    } else {
      $scope.billing.sort.column = column;
      $scope.billing.sort.descending = false;
    }
  };

  /**
   * Sorting on "amount" is conditional on the type of filter selected - we want to sort on
   * "itemBalance" under the "Balance" view, and "itemLineAmount" under all other views.
   */
  $scope.changeSortingAmount = function() {
    if ($scope.filter.choice === 'balance') {
      $scope.changeSorting('itemBalance');
    } else {
      $scope.changeSorting('itemLineAmount');
    }
  };

  $scope.choiceChange = function() {
    resetSearch();
    if ($scope.filter.choice === 'balance') {
      $scope.filter.searchStatus = $scope.filter.statuses.balance;
    } else if ($scope.filter.choice === 'transactions' || $scope.filter.choice === 'daterange') {
      // On default, we want to see all items, not just unpaid ones
      $scope.filter.searchStatus = $scope.filter.statuses.allTransactions;
    } else if ($scope.filter.choice === 'term') {
      $scope.filter.searchStatus = $scope.filter.statuses.allTransactions;
      selectDefaultTerm($scope.billing.data.summary);
    }
  };

  $scope.dateFilter = function(billingItem) {
    if ($scope.filter.parsedDates.startDt && $scope.filter.parsedDates.endDt) {
      return (_.gte(billingItem.itemEffectiveDate, $scope.filter.parsedDates.startDt) && _.lte(billingItem.itemEffectiveDate, $scope.filter.parsedDates.endDt));
    }
    if ($scope.filter.parsedDates.startDt) {
      return _.gte(billingItem.itemEffectiveDate, $scope.filter.parsedDates.startDt);
    }
    if ($scope.filter.parsedDates.endDt) {
      return _.lte(billingItem.itemEffectiveDate, $scope.filter.parsedDates.endDt);
    }
    return true;
  };

  $scope.getSortClass = function(column) {
    var sortUpDown = $scope.billing.sort.descending ? 'down' : 'up';
    return _.isEqual($scope.billing.sort.column, column) && 'fa fa-chevron-' + sortUpDown;
  };

  $scope.getSortClassAmount = function() {
    if ($scope.filter.choice === 'balance') {
      return $scope.getSortClass('itemBalance');
    } else {
      return $scope.getSortClass('itemLineAmount');
    }
  };

  $scope.parseEndDt = function(date) {
    $scope.filter.parsedDates.endDt = apiService.financials.createDateValues(date);
  };

  $scope.parseStartDt = function(date) {
    $scope.filter.parsedDates.startDt = apiService.financials.createDateValues(date);
  };

  $scope.printPage = function() {
    apiService.financials.printPage();
  };

  $scope.statusFilter = function(billingItem) {
    if (_.isArray($scope.filter.searchStatus)) {
      return (_.includes($scope.filter.searchStatus, billingItem.itemStatus));
    }
    return (!_.isEqual($scope.filter.searchStatus, billingItem.itemBalance));
  };

  loadBillingInfo();
});
