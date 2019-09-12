import formatDate from 'functions/formatDate';

const dueLabel = (date) => {
  if (date !== null) {
    return `Due ${ formatDate(date) }`;
  }
};

export default dueLabel;
