const formatCurrency = (amount) => {
  const sign = Math.abs(amount) === amount ? '$' : '- $';

  const formatted = Math.abs(amount).toLocaleString('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).slice(1);

  return `${sign} ${formatted}`;
};

export default formatCurrency;
