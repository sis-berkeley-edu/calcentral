export const groupByDate = (accumulator, message) => {
  const group = accumulator.find(group => group.date === message.statusDate);

  if (group) {
    group.messages.unshift(message);
  } else {
    accumulator.push({ date: message.statusDate, messages: [message] });
  }

  return accumulator;
};

export const groupBySource = (accumulator, message) => {
  const group = accumulator.find(group => group.sourceName === message.source);

  if (group) {
    group.messages.push(message);
  } else {
    accumulator.push({ sourceName: message.source, messages: [message] });
  }

  return accumulator;
};

export const byStatusDateTimeAsc = (a, b) => {
  return a.statusDateTime < b.statusDateTime ? 1 : -1;
};

export const dateSourcedMessages = group => {
  return {
    date: group.date,
    messagesBySource: group.messages.reduce(groupBySource, []),
  };
};

export const filterByAidYear = year => notification =>
  notification.isFinaid && notification.aidYear == year;
