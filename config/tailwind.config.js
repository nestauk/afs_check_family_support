const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim,rblade}'
  ],
  theme: {
    boxShadow: {
      "0": "0 0 rgb(0,0,0)",
      "1": "0 1px rgb(0,0,0)",
      "2": "0 2px rgb(0,0,0)",
      "3": "0 3px rgb(0,0,0)",
      "4": "0 4px rgb(0,0,0)",
    },
    extend: {
      colors: {
        "focus": "#9aff3c"
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
    require('../vendor/javascript/tailwindcss-unimportant')
  ]
}
