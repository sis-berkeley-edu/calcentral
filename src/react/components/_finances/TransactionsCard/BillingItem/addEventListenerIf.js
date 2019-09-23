const addEventListenerIf = (expanded, handler) => {
  if (expanded) {
    document.addEventListener('mousedown', handler);
  } else {
    document.removeEventListener('mousedown', handler);
  }

  return () => {
    document.removeEventListener('mousedown', handler);
  };
};

export default addEventListenerIf;
