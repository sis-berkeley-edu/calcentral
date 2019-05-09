export const formatGpaCumulative = (gpa) => {
  if (gpa.role === 'law') {
    return 'N/A';
  } else {
    return parseFloat(gpa.cumulativeGpa).toFixed(3);
  }
};
