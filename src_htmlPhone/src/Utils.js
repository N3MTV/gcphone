const colors = ['#448AFF', '#E040FB', '#E64A19', '#4CAF50', '#455A64', '#009688']

export function groupBy (xs, key) {
  return xs.reduce(function (rv, x) {
    (rv[x[key]] = rv[x[key]] || []).push(x)
    return rv
  }, {})
}

export function generateColorForStr (str) {
  if (str.length === 0 || str[0] === '#') {
    return '#D32F2F'
  }
  const h = str.split('').reduce((prevHash, currVal) =>
    (((prevHash << 5) - prevHash) + currVal.charCodeAt(0)) | 0
  , 0)
  return colors[Math.abs(h) % colors.length]
}
