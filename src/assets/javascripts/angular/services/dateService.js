'use strict';

import { format, parseISO, formatDistance } from 'date-fns';

angular.module('calcentral.services').service('dateService', [
  function() {
    var dateService = {
      now: Date.now(),
      format: (string, formatString) => {
        return format(parseISO(string), formatString);
      },
      formatDistance,
    };

    return dateService;
  },
]);
