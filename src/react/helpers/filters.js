export function usdFilter(value) {
  let usdString = Number.parseFloat(value).toFixed(2);
  return `$ ${usdString}`;
}
