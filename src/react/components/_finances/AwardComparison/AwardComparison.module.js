const mergeSubvalues = (current, snapshot) => {
  const currentTerms = current ? current.map(item => item.term) : null;
  const snapshotTerms = snapshot ? snapshot.map(item => item.term) : null;

  const combinedTerms = snapshotTerms
    ? new Set(currentTerms.concat(snapshotTerms))
    : new Set(currentTerms);

  return Array.from(combinedTerms).map(term => {
    return {
      term: term,
      currentValue:
        current && current.find(item => item.term === term)
          ? current.find(item => item.term === term).value
          : null,
      snapshotValue:
        snapshot && snapshot.find(item => item.term === term)
          ? snapshot.find(item => item.term === term).value
          : null,
    };
  });
};

export const countDifferencesBetween = (snapshot, current) => {
  if (snapshot && current) {
    if (snapshot.value || current.value) {
      return snapshot.description === current.description &&
        snapshot.value === current.value
        ? 0
        : 1;
    } else if (snapshot.subvalues) {
      const merged = mergeSubvalues(current.subvalues, snapshot.subvalues);

      return merged.reduce((acc, item) => {
        return acc + (item.currentValue === item.snapshotValue ? 0 : 1);
      }, 0);
    } else {
      return 0;
    }
  } else {
    return 1;
  }
};

export const differencesBetween = aArray => bArray => {
  return aArray.reduce((accumulator, current) => {
    const matchingItem = bArray.find(
      b => b.description === current.description
    );

    return accumulator + countDifferencesBetween(current, matchingItem);
  }, 0);
};

export const countTheChanges = (current, snapshot) => {
  const { items: currentItems = [] } = current || {};
  const { items: snapshotItems = [] } = snapshot || {};

  if (snapshotItems.length === 0) {
    return 0;
  }

  return differencesBetween(currentItems)(snapshotItems);
};
