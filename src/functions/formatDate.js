import format from 'date-fns/format';
import parseISO from 'date-fns/parseISO';
import {
  isThisYear,
  isFuture as datefnsIsFuture,
  isPast as datefnsIsPast,
} from 'date-fns';

export const isFuture = date => datefnsIsFuture(date);
export const isPast = date => datefnsIsPast(date);
export const parseDate = string => parseISO(string);

export const formats = {
  timeOfDay: 'h:mma',
  timeNoMeridian: 'h:mm',
  merdian: 'a',
  lowerMeridian: 'aaaa',
  monthDay: 'MMM d',
  monthDayYear: 'MMM d, y',
};

export const formatDate = date => format(date, formats.monthDayYear);

export const shortDate = date => format(date, formats.monthDay);

export const shortDateIfCurrentYear = date => {
  if (isThisYear(date)) {
    return shortDate(date);
  }

  return formatDate(date);
};

export const formatTime = date => {
  return format(date, formats.timeOfDay);
};

export default formatDate;
