'use strict';

import { format, parseISO } from 'date-fns';

angular.module('calcentral.services').service('dateService', [
  function() {
    var dateService = {
      now: Date.now(),
      format: (string, formatString) => {
        return format(parseISO(string), formatString);
      },
    };

    return dateService;
  },
]);
