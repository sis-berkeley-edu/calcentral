import { formatISO } from 'date-fns';

const toISODateString = date => {
  return formatISO(date, { representation: 'date' });
};

export const groupByDate = (accumulator, message) => {
  const group = accumulator.find(
    group => group.dateString === toISODateString(message.statusDate)
  );

  if (group) {
    group.messages.push(message);
  } else {
    accumulator.push({
      dateString: toISODateString(message.statusDate),
      date: message.statusDate,
      messages: [message],
    });
  }

  return accumulator;
};

const groupBySourceAndType = (accumulator, message) => {
  const group = accumulator.find(
    group => group.sourceName === message.source && group.type === message.type
  );

  if (group) {
    group.messages.push(message);
  } else {
    accumulator.push({
      sourceName: message.source,
      type: message.type,
      messages: [message],
    });
  }

  return accumulator;
};

export const byStatusDateTimeAsc = (a, b) => {
  return a.statusDateTime < b.statusDateTime ? 1 : -1;
};

export const dateAndTypeSourcedMessages = group => {
  return {
    date: group.date,
    messagesBySource: group.messages.reduce(groupBySourceAndType, []),
  };
};

export const filterByAidYear = year => notification =>
  notification.isFinaid && notification.aidYear == year;
