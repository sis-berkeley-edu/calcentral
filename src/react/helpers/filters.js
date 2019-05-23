export function usdFilter(value) {
  return '$ ' + value.toLocaleString('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  }).slice(1);
}
