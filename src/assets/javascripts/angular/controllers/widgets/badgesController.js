'use strict';

/**
 * Badges controller
 */

angular.module('calcentral.controllers').controller('BadgesController', function(badgesFactory, dateService, errorService, $scope) {
  var defaults = {
    'bcal': {
      'count': '...',
      'display': {
        'additionalClasses': 'cc-icon-calendar',
        'href': 'http://bcal.berkeley.edu',
        'name': 'bCal',
        'title': 'Outstanding bCal activity for the next 30 days'
      }
    },
    'bmail': {
      'count': '...',
      'display': {
        'additionalClasses': 'cc-icon-mail',
        'href': 'http://bmail.berkeley.edu',
        'name': 'bMail',
        'title': 'Unread bMail messages from the past 30 days'
      }
    },
    'bdrive': {
      'display': {
        'additionalClasses': 'cc-icon-drive',
        'href': 'http://bdrive.berkeley.edu',
        'name': 'bDrive',
        'title': 'Changes to bDrive documents made in the past 30 days'
      }
    }
  };

  var defaultOrder = ['bmail', 'bcal', 'bdrive'];

  var dateFormats = {
    today: 'h:mm aaaa',
    // No need for formatting due to the left calendar widget.
    todayAllDay: '',
    notToday: '(MM/dd) h:mm aaaa',
    notTodayAllDay: 'MM/dd(E)',
    datestamp: 'yyyyMMdd'
  };

  var processDisplayRange = function(epoch, isAllDay, isStartRange) {
    var date = new Date(epoch * 1000);
    var today = dateService.format(dateService.now, dateFormats.datestamp);
    var dateIsToday = dateService.format(date, dateFormats.datestamp) === today;

    // not all day event, happening today.
    if (dateIsToday && !isAllDay) {
      return dateService.format(date, dateFormats.today);
    } else if (!dateIsToday && !isAllDay) {
      // not all day event, not happening today.
      if (isStartRange) {
        // start-range display doesn't need a date display since it's on the left graphic
        return dateService.format(date, dateFormats.today);
      } else {
        return dateService.format(date, dateFormats.notToday);
      }
    } else if (!dateIsToday && isAllDay) {
      // all day event, not happening today.
      return dateService.format(date, dateFormats.notTodayAllDay);
    } else if (dateIsToday && isAllDay) {
      // all day event, happening today. No need for the range since the date's on the left.
      return '';
    } else {
      errorService.send('badgesController - unidentifiable date display range');
      return '';
    }
  };

  var decorateBadges = function(rawData) {
    defaultOrder.forEach(function(value, index) {
      if ($scope.badges.length > index &&
        $scope.badges[index].display.name.toLowerCase() === value) {
        $scope.badges[index].cssPopover = 'cc-' + $scope.badges[index].display.name + '-popover-status';
        angular.extend($scope.badges[index], rawData[value]);
      }
    });
  };

  /**
   * Convert a normal badges hash into an custom ordered array of badges.
   * @param {Object} badgesHash badges hash keyed by badge name
   * @return {Array} array of badges
   */
  var orderBadges = function(badgesHash) {
    var returnArray = [];
    defaultOrder.forEach(function(value) {
      returnArray.push(badgesHash[value] || {});
    });
    return returnArray;
  };

  var timeElapsed = function(time) {
    return dateService.formatDistance(new Date(), new Date(time * 1000), { addSuffix: true });
  };

  var processCalendarEvents = function(rawData) {
    if (rawData.bcal && rawData.bcal.items) {
      rawData.bcal.items.forEach(function(value) {
        if (value.startTime && value.startTime.epoch) {
          var startTime = new Date(value.startTime.epoch * 1000);
          value.startTime.display = {
            'month': dateService.format(startTime, 'MMM'),
            'day': dateService.format(startTime, 'dd'),
            'dayOfWeek': dateService.format(startTime, 'EEE'),
            'rangeStart': processDisplayRange(value.startTime.epoch, value.allDayEvent, true)
          };

          if (value.endTime && value.endTime.epoch) {
            value.endTime.display = {
              'rangeEnd': processDisplayRange(value.endTime.epoch, value.allDayEvent, false)
            };
          }
        }
        value.modifiedTimeElapsed = timeElapsed(value.modifiedTime.epoch);
      });
    }
  };

  var processDriveEvents = function(rawData) {
    if (rawData.bdrive && rawData.bdrive.items) {
      rawData.bdrive.items.forEach(function(value) {
        value.modifiedTimeElapsed = timeElapsed(value.modifiedTime.epoch);
      });
    }
  };

  var processEvents = function(rawData) {
    processCalendarEvents(rawData);
    processDriveEvents(rawData);
    return rawData;
  };

  var fetch = function(options) {
    badgesFactory.getBadges(options).then(
      function successCallback(response) {
        decorateBadges(processEvents(response.data.badges || {}));
      }
    );
  };

  /**
   * To avoid watching two the values below separately, and running into a situation
   * where it could trigger multiple fetch calls, the watch call has been merged. This might
   * have also cleared up a rendering delay issue, since $digest might have been working unnecessarily
   * hard on $scope.badges
   */
  $scope.$watch('api.user.profile.isLoggedIn + \',\' + api.user.profile.hasGoogleAccessToken', function(newTokenTuple) {
    if (newTokenTuple.split(',')[0] === 'true') {
      fetch();
    }
  });

  $scope.badges = orderBadges(defaults);
});
