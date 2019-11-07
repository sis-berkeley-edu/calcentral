export const keyForTask = (task, index, prefix) => {
  if (task.type) {
    return `${prefix}-${task.type}-${index}`;
  } else {
    return `${prefix}-${task.displayCategory}-${index}-${task.aidYear}`;
  }
};

export const checklistCategoryTitles = [
  { key: 'overdue', title: 'Overdue' },
  {
    key: 'agreements',
    title: 'Agreements and Opt-ins',
  },
  {
    key: 'admission',
    title: 'Admission Tasks',
  },
  {
    key: 'residency',
    title: 'Residency Tasks',
  },
  {
    key: 'financialAid',
    title: 'Finances Tasks',
  },
  {
    key: 'newStudent',
    title: 'New Student Tasks',
  },
  {
    key: 'student',
    title: 'Student Tasks',
  },
];

const byAirYearReducer = (accumulator, value) => {
  accumulator[value.aidYear] = accumulator[value.aidYear]
    ? [...accumulator[value.aidYear], value]
    : [value];

  return accumulator;
};

export const groupByAidYear = items => {
  return items.reduce(byAirYearReducer, {});
};

export const groupByCategory = (accumulator, value) => {
  if (value.isOverdue) {
    if (accumulator.hasOwnProperty('overdue')) {
      accumulator['overdue'].push(value);
    } else {
      accumulator['overdue'] = [value];
    }
  } else {
    if (accumulator.hasOwnProperty(value.displayCategory)) {
      accumulator[value.displayCategory].push(value);
    } else {
      accumulator[value.displayCategory] = [value];
    }
  }

  return accumulator;
};
