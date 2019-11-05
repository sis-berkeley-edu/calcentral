'use strict';

angular
  .module('calcentral.services')
  .service('widgetService', function(analyticsService) {
    /*
     * Toggle whether an item for a widget should be shown or not.
     * Used with items listed in a widget, closing all other items
     * when a single item is shown.
     */
    var toggleShow = function(event, items, item, widget) {
      var ignoreTogglingTags = ['A', 'BUTTON', 'I', 'INPUT', 'TEXTAREA'];
      var nodeName = event && event.target && event.target.nodeName;
      if (nodeName && ignoreTogglingTags.indexOf(nodeName) !== -1) {
        return;
      }
      // Toggle the current item
      item.show = !item.show;

      // Hide all the other items
      if (angular.isArray(items)) {
        for (var i = 0; i < items.length; i++) {
          if (items[i].$$hashKey !== item.$$hashKey) {
            items[i].show = false;
          }
        }
      }

      // Also make it work for objects
      if (angular.isObject(items)) {
        for (var j in items) {
          if (
            items.hasOwnProperty(j) &&
            items[j].$$hashKey !== item.$$hashKey
          ) {
            items[j].show = false;
          }
        }
      }
      analyticsService.sendEvent(
        'Detailed view',
        item.show ? 'Open' : 'Close',
        widget
      );
    };

    // Expose the methods
    return {
      toggleShow: toggleShow,
    };
  });
