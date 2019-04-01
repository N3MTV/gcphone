import store from '@/store'

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
  return store.getters.colors[Math.abs(h) % store.getters.colors.length]
}

export function getBestFontColor (color) {
  const rgb = getRGB(color)
  if (rgb === undefined) {
    return '#000000'
  } else {
    if (rgb.red * 0.299 + rgb.green * 0.587 + rgb.blue * 0.114 > 186) {
      return 'rgba(0, 0, 0, 0.87)'
    } else {
      return '#FFFFFF'
    }
  }
}
