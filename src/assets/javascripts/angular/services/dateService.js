'use strict';

import { format, isDate, parseISO, formatDistance } from 'date-fns';

angular.module('calcentral.services').service('dateService', [
  function() {
    var dateService = {
      now: Date.now(),
      format: (date, formatString) => {
        if (isDate(date)) {
          return format(date, formatString);
        } else if (typeof date === 'number') {
          return format(new Date(date), formatString);
        } else if (typeof date === 'string') {
          return format(parseISO(date), formatString);
        } else {
          throw "date object must be a date, epoch number, or ISO string";
        }
      },
      formatDistance,
      formats: {
        long: 'MMMM do, yyyy',
      },
    };

    return dateService;
  },
]);
