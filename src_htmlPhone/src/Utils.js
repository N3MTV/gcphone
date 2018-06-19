const colors = [
  '#EF5350',
  '#EC407A',
  '#AB47BC',
  '#7E57C2',
  '#5C6BC0',
  '#42A5F5',
  '#29B6F6',
  '#26C6DA',
  '#26A69A',
  '#66BB6A',
  '#9CCC65',
  '#D4E157',
  // '#FFEE58',
  '#FFCA28',
  '#FFA726',
  '#FF7043',
  '#8D6E63',
  // '#BDBDBD',
  '#78909C'
]

function getRGB (colorStr) {
  let match = colorStr.match(/rgba?\((\d{1,3}), ?(\d{1,3}), ?(\d{1,3})\)?(?:, ?(\d(?:\.\d?))\))?/)
  if (match !== null) {
    return {
      red: parseInt(match[1], 10),
      green: parseInt(match[2], 10),
      blue: parseInt(match[3], 10)
    }
  }
  match = colorStr.match(/^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})/)
  if (match !== null) {
    return {
      red: parseInt(match[1], 16),
      green: parseInt(match[2], 16),
      blue: parseInt(match[3], 16)
    }
  }
  return undefined
}

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

export function getBestFontColor (color) {
  const rgb = getRGB(color)
  if (rgb === undefined) {
    return '#000000'
  } else {
    console.log(rgb)
    if (rgb.red * 0.299 + rgb.green * 0.587 + rgb.blue * 0.114 > 186) {
      return 'rgba(0, 0, 0, 0.87)'
    } else {
      return '#FFFFFF'
    }
  }
}
