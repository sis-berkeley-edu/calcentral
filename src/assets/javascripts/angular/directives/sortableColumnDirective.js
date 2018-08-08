'use strict';



/*
 * CalCentral Sortable Column Directive
 *
 * Facilitates the sorting of the data in the table based on the selected column.
 * Requires that the parent controller have a tableSort setting in the parent scope to define the
 * column to sort on by default. Requires that your table use an ngRepeat with an orderBy filter applied
 * that orders based on the tableSort properties.
 *
 * Example:
 *   <tbody data-ng-repeat="row in orderedRows = (rows | orderBy:tableSort.column:tableSort.reverse)"
 */
angular.module('calcentral.directives').directive('ccSortableColumnDirective', function() {
  return {
    scope: true,
    link: function(scope, elem, attrs) {
      scope.sortAttribute = attrs.ccSortableColumnDirective;
      scope.columnHeading = attrs.columnHeading;
      scope.applySort = function(sortAttribute) {
        scope.tableSort.reverse = (scope.tableSort.column === sortAttribute ? !scope.tableSort.reverse : false);
        scope.tableSort.column = sortAttribute;
      };
    },
    templateUrl: 'directives/sortable_column.html'
  };
});
