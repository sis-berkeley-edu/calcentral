// Used as a filter function isPresent removes items that are falsy
//
// const result = [0, 1, 2, 3, 4, null, false].filter(isPresent)
// console.log(result) // => [1, 2, 3, 4]
export default function isPresent(item) {
  return item;
}
