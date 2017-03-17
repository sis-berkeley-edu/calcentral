'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Financial Aid - Awards controller
 */
angular.module('calcentral.controllers').controller('FinaidAwardsCompareController', function(
  $location,
  $q,
  $routeParams,
  $scope,
  finaidFactory,
  finaidService) {

  // Expose everything to the view.
  $scope.finaidAwardsCompare = {
    information: {},
    isLoading: true,
    isLoadingCurrentAndPrior: false,
    data: {
      current: {},
      list: {},
      prior: {}
    },
    sections: [
      {
        id: 'summary',
        title: 'Summary Information'
      },
      {
        id: 'netcost',
        title: 'Net Cost'
      },
      {
        id: 'packages',
        title: 'Packages'
      }
    ],
    selected: {
      aidYear: '',
      package: ''
    },
    showCurrentAndPrior: false,
    toggle: {},
    types: [
      {
        title: 'Prior',
        id: 'prior'
      },
      {
        title: 'Current',
        id: 'current'
      }
    ]
  };
  $scope.isMainFinaid = false;

  /**
   * The title for section categories/items that contain the total for other categories/other
   * items in that category.
   */
  var grandTotalTitle = 'Grand Total';

  /**
   * Check whether we should update the URL or not
   */
  var checkUpdateUrl = function() {
    if ($routeParams.finaidYearId !== finaidService.options.finaidYear.id) {
      $location.path('finances/finaid/compare/' + finaidService.options.finaidYear.id, false);
    }
  };

  /**
   * Set the Financial Aid year to what's available in the service
   */
  var setFinaidYear = function() {
    $scope.finaidAwardsCompare.selected.aidYear = finaidService.options.finaidYear;
  };

  /**
   * Parse the list of packages
   */
  var parseFinaidAwardCompareList = function(response) {
    $scope.finaidAwardsCompare.data.list = _.get(response, 'data.feed.awardParms');
    $scope.finaidAwardsCompare.errored = response.errored;
    $scope.finaidAwardsCompare.isLoading = false;
  };

  /**
   * Get the list of all the packages on different dates and times
   */
  var getFinaidAwardCompareList = function() {
    return finaidFactory.getAwardCompareList({
      finaidYearId: finaidService.options.finaidYear.id
    }).then(parseFinaidAwardCompareList);
  };

  /**
   * Select the first package in the dropdown (if there are any)
   */
  var selectFirstPackage = function() {
    var packages = _.get($scope, 'finaidAwardsCompare.data.list.data');
    if (_.get(packages, 'length')) {
      $scope.finaidAwardsCompare.selected.package = packages[0];
    }
  };

  /**
   * Find the change in current from prior.
   */
  var findChange = function(current, prior) {
    if (prior === null) {
      if (current !== null) {
        return $scope.changeTags.added;
      }
    } else if (current === null) {
      if (prior !== null) {
        return $scope.changeTags.deleted;
      }
    } else if (prior !== current) {
      return $scope.changeTags.changed;
    }
    return $scope.changeTags.same;
  };

  /**
   * Parse a set of summary items from a list of titles, normalizing all items and using a default
   * values for missing items.
   */
  var parseSummaryItems = function(titles, itemsByTitle) {
    return _.map(titles, function(title) {
      var item = itemsByTitle[title];
      if (item) {
        switch (title) {
          case 'Enrollment': {
            _.forEach(item.values, function(value) {
              value.subvalue = [value.subvalue[0] + ': ' + value.subvalue[1] + ' units'];
            });
            return {
              title: item.title,
              values: item.values
            };
          }
          case 'Expected Family Contribution (EFC)':
          case 'Berkeley Parent Contribution': {
            return {
              title: item.title,
              values: [{
                isAmount: !_.isNaN(_.toNumber(item.value)),
                subvalue: [item.value]
              }]
            };
          }
          default: {
            return {
              title: item.title,
              values: item.values || [{
                subvalue: [item.value]
              }]
            };
          }
        }
      }
      return {
        title: title,
        values: []
      };
    });
  };

  /**
   * Parse current and prior data for the Summary Information section.
   */
  var parseSummaryData = function(data) {
    var priorData = _.flatten(_.get(data, 'prior.data.feed.status.categories[0].itemGroups'));
    var currentData = _.flatten(_.get(data, 'current.data.feed.status.categories[0].itemGroups'));

    // Ensure both current and prior have the same normalized items in the same order.
    var priorItemsByTitle = _.keyBy(priorData, 'title');
    var currentItemsByTitle = _.keyBy(currentData, 'title');
    var titles = _.union(_.map(_.concat(priorData, currentData), 'title'));
    var priorItems = parseSummaryItems(titles, priorItemsByTitle);
    var currentItems = parseSummaryItems(titles, currentItemsByTitle);

    // Ensure both current and prior have items with values  of the same length.
    _.forEach(_.zip(priorItems, currentItems), function(zippedItem) {
      var priorItem = zippedItem[0];
      var currentItem = zippedItem[1];
      var numValues = _.max([priorItem.values.length, currentItem.values.length]);
      if (priorItem.values.length < numValues) {
        priorItem.values = _.times(numValues, _.constant(''));
        currentItem.change = $scope.changeTags.added;
      } else if (currentItem.values.length < numValues) {
        currentItem.values = _.times(numValues, _.constant(''));
        currentItem.change = $scope.changeTags.deleted;
      } else {
        if (_.isEqual(priorItem.values, currentItem.values)) {
          currentItem.change = $scope.changeTags.same;
        } else {
          currentItem.change = $scope.changeTags.changed;
        }
      }
    });

    $scope.finaidAwardsCompare.data.prior.summary = priorItems;
    $scope.finaidAwardsCompare.data.current.summary = currentItems;
  };

  /**
   * Parse current and prior data for the Net Cost section.
   */
  var parseNetcostData = function(data) {
    var priorNetcost = _.get(data, 'prior.data.feed.coa.fullyear.data');
    var currentNetcost = _.get(data, 'current.data.feed.coa.fullyear.data');
    _.forEach(_.zip(priorNetcost, currentNetcost), function(zippedCategory) {
      var priorCategory = zippedCategory[0];
      var currentCategory = zippedCategory[1];
      _.forEach(_.zip(priorCategory.items, currentCategory.items), function(zippedItem) {
        var priorItem = zippedItem[0];
        var currentItem = zippedItem[1];

        // Ensure both priorItem and currentItem have the same subItems in the same order.
        var pairedSubItems = {};
        _.forEach(priorItem.subItems, function(subItem) {
          pairedSubItems[subItem.title] = pairedSubItems[subItem.title] || [null, null];
          pairedSubItems[subItem.title][0] = subItem.total;
        });
        _.forEach(currentItem.subItems, function(subItem) {
          pairedSubItems[subItem.title] = pairedSubItems[subItem.title] || [null, null];
          pairedSubItems[subItem.title][1] = subItem.total;
        });
        var unzippedSubItems = _.unzip(_.map(pairedSubItems, function(total, title) {
          var priorTotal = total[0];
          var currentTotal = total[1];
          return [
            {
              title: title,
              total: priorTotal
            },
            {
              title: title,
              total: currentTotal,
              change: findChange(currentTotal, priorTotal)
            }
          ];
        }));
        priorItem.subItems = unzippedSubItems[0];
        currentItem.subItems = unzippedSubItems[1];
        if (currentItem.total) {
          currentItem.change = findChange(currentItem.total, priorItem.total);
        } else if (currentItem.totals) {
          currentItem.change = findChange(_.last(currentItem.totals), _.last(priorItem.totals));
        }

        // Bind show for priorItem and currentItem.
        $scope.$watch(function() {
          return priorItem.show;
        }, function(show) {
          if (show !== currentItem.show) {
            currentItem.show = show;
          }
        });
        $scope.$watch(function() {
          return currentItem.show;
        }, function(show) {
          if (show !== priorItem.show) {
            priorItem.show = show;
          }
        });
      });
      priorCategory.change = $scope.changeTags.blank;
      currentCategory.change = $scope.changeTags.blank;
    });
    $scope.finaidAwardsCompare.data.prior.netcost = priorNetcost;
    $scope.finaidAwardsCompare.data.current.netcost = currentNetcost;
  };

  /**
   * Parse current and prior data for the Packages section.
   */
  var parsePackagesData = function(data) {
    var priorData = _.get(data, 'prior.data.feed.awards.semester.data');
    var currentData = _.get(data, 'current.data.feed.awards.semester.data');

    // Ensure both current and prior have the same categories in the same order not considering
    // the Grand Total category (which is assumed to be the last category).
    var priorCategoriesByTitle = _.keyBy(priorData, 'title');
    var currentCategoriesByTitle = _.keyBy(currentData, 'title');
    var titleAndHeaders =
      _.unionBy(_.map(_.concat(_.dropRight(currentData), _.dropRight(priorData)), function(category) {
        return {
          title: category.title,
          headers: category.headers
        };
      }), 'title');
    var priorPackages = _.map(titleAndHeaders, function(titleAndHeader) {
      return priorCategoriesByTitle[titleAndHeader.title] || titleAndHeader;
    });
    var currentPackages = _.map(titleAndHeaders, function(titleAndHeader) {
      return currentCategoriesByTitle[titleAndHeader.title] || titleAndHeader;
    });

    _.forEach(_.zip(priorPackages, currentPackages), function(zippedCategory) {
      var priorCategory = zippedCategory[0];
      var currentCategory = zippedCategory[1];

      // Ensure both currentCategory and priorCategory have the same items in the same order
      // not considering the Grand Total item (which is assumed to be the last item).
      var numAmounts = priorCategory.headers.length;
      var amountsTemplate = _.times(numAmounts, _.constant(null));
      var pairedAmountsTemplate = _.times(2, function() {
        return amountsTemplate;
      });
      var pairedItems = {};
      _.forEach(_.dropRight(priorCategory.items), function(item) {
        pairedItems[item.title] = pairedItems[item.title] || _.cloneDeep(pairedAmountsTemplate);
        pairedItems[item.title][0] = _.concat(item.amounts, item.total);
      });
      _.forEach(_.dropRight(currentCategory.items), function(item) {
        pairedItems[item.title] = pairedItems[item.title] || _.cloneDeep(pairedAmountsTemplate);
        pairedItems[item.title][1] = _.concat(item.amounts, item.total);
      });
      var unzippedItems = _.unzip(_.map(pairedItems, function(amounts, title) {
        return [
          {
            title: title,
            amounts: _.dropRight(amounts[0]),
            total: _.last(amounts[0])
          },
          {
            title: title,
            amounts: _.dropRight(amounts[1]),
            total: _.last(amounts[1]),
            change: findChange(_.last(amounts[1]), _.last(amounts[0]))
          }
        ];
      }));

      // Re-add the Grand Total item.
      var priorGrandTotalItem = _.last(priorCategory.items) || {
          title: grandTotalTitle,
          totals: _.clone(amountsTemplate)
        };
      priorCategory.items = _.concat(unzippedItems[0], priorGrandTotalItem);
      priorCategory.change = $scope.changeTags.blank;
      var currentGrandTotalItem = _.last(currentCategory.items) || {
          title: grandTotalTitle,
          totals: _.clone(amountsTemplate)
        };
      currentGrandTotalItem.change =
        findChange(_.last(currentGrandTotalItem.totals), _.last(priorGrandTotalItem.totals));
      currentCategory.items = _.concat(unzippedItems[1], currentGrandTotalItem);
      currentCategory.change = $scope.changeTags.blank;
    });

    // Re-add the Grand Total category.
    var priorGrandTotalCategory = priorCategoriesByTitle[grandTotalTitle];
    if (priorGrandTotalCategory) {
      priorGrandTotalCategory.change = $scope.changeTags.blank;
      priorPackages.push(priorGrandTotalCategory);
    }
    var currentGrandTotalCategory = currentCategoriesByTitle[grandTotalTitle];
    if (currentGrandTotalCategory) {
      currentGrandTotalCategory.change = $scope.changeTags.blank;
      _.get(currentGrandTotalCategory, 'items[0]').change = findChange(
        _.last(_.get(currentGrandTotalCategory, 'items[0].amounts')),
        _.last(_.get(priorGrandTotalCategory, 'items[0].amounts'))
      );
      currentPackages.push(currentGrandTotalCategory);
    }

    $scope.finaidAwardsCompare.data.prior.packages = priorPackages;
    $scope.finaidAwardsCompare.data.current.packages = currentPackages;
  };

  /**
   * Parse the current and prior package data
   */
  var parseCurrentAndPrior = function(response) {
    parseSummaryData(response);
    parseNetcostData(response);
    parsePackagesData(response);
  };

  /**
   * Load the current and prior data after changing the selected option in the dropdown
   */
  var loadCurrentAndPrior = function(priorDate) {
    if (!priorDate) {
      $scope.finaidAwardsCompare.data.current = {};
      $scope.finaidAwardsCompare.data.prior = {};
      $scope.finaidAwardsCompare.showCurrentAndPrior = false;
    } else {
      $scope.finaidAwardsCompare.isLoadingCurrentAndPrior = true;
      $scope.finaidAwardsCompare.showCurrentAndPrior = true;
      $q.all({
        current: finaidFactory.getAwardCompareCurrent({
          finaidYearId: finaidService.options.finaidYear.id
        }),
        prior: finaidFactory.getAwardComparePrior({
          finaidYearId: finaidService.options.finaidYear.id,
          date: priorDate.csdate
        })
      }).then(function(response) {
        parseCurrentAndPrior(response);
        $scope.finaidAwardsCompare.isLoadingCurrentAndPrior = false;
      });
    }
  };

  /**
   * By default, show all the different sections (e.g. "Summary Information", "Net Cost")
   */
  var showSectionsByDefault = function() {
    _.forEach($scope.finaidAwardsCompare.sections, function(section) {
      $scope.finaidAwardsCompare.toggle[section.id] = {
        show: true
      };
    });
  };

  /**
   * Load the compare list
   */
  var loadFinaidAwardsCompareList = function() {
    checkUpdateUrl();
    setFinaidYear();

    return getFinaidAwardCompareList()
      .then(selectFirstPackage);
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadFinaidAwardsCompareList);
  $scope.$watch('finaidAwardsCompare.selected.package', loadCurrentAndPrior);
  showSectionsByDefault();
});
