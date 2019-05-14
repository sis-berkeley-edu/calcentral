export const forTermId = (list, termId) => list.find(item => item.termId === termId);

export const termFromId = (id) => {
  id = id.toString();

  const year = id.slice(0, -1) === '1' ? `19${id.slice(1, 3)}` : `20${id.slice(1, 3)}`;
  const semester = {
    '0': 'Winter',
    '2': 'Spring',
    '5': 'Summer',
    '8': 'Fall'
  }[id.slice(-1)];

  return { id, semester, year };
};
