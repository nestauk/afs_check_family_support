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
    colors: {
      "black": "#000",
      "white": "#FFF",
      "transparent": "transparent",
      "current": "currentColor",

      "focus": "#9aff3c", //                                  Black AAA
      "error": "#EB0F0F", //                  White AA        Black AA
      "success": "#1B8848", //                White AA        Black AA

      "blue": {
        DEFAULT: "#0000FF",
        50: "#F0F0FF",
        100: "#E5E5FF",
        200: "#C2C2FF",
        300: "#9999FF", // Nesta Blue/40                      Black AAA
        400: "#6B6BFF", //                    White AA (L)    Black AA
        500: "#4C4CFF", // Nesta Blue/70      White AA        Black AA (L)
        600: "#2424FF", //                    White AAA
        700: "#0000FF", // Nesta Blue/100
        800: "#0000DB",
        900: "#00008F",
        950: "#000066",
      },

      "green": {
        DEFAULT: "#18A48C",
        50: "#F0F9F8",
        100: "#E5F5F2",
        200: "#C4E8E2",
        300: "#A3DBD1", // Nesta Green/40
        400: "#72D4C4",
        500: "#5DBFAE", // Nesta Green/70
        600: "#26B59E", //                                    Black AAA
        700: "#18A48C", // Nesta Green/100    White AA (L)
        800: "#148572", //                    White AA        Black AA
        900: "#0C5549", //                    White AAA
        950: "#051F1B",
      },

      "aqua": {
        DEFAULT: "#97D9E3",
        50: "#F6FDFE",
        100: "#F2FBFD",
        200: "#E1F6F9",
        300: "#D5F0F4", // Nesta Aqua/40
        400: "#C5ECF2",
        500: "#B6E4EB", // Nesta Aqua/70
        600: "#A5DFE8",
        700: "#97D9E3", // Nesta Aqua/100
        800: "#3CBACE", //                                    Black AAA
        900: "#248998", //                    White AA (L)    Black AA
        950: "#19616C", //                    White AAA
      },

      "red": {
        DEFAULT: "#EA2541",
        50: "#FFF0F4",
        100: "#FFE5EC",
        200: "#FFD6E0",
        300: "#F799B1", // Nesta Red/40
        400: "#EE7C8D", //                                    Black AAA
        500: "#F14C76", // Nesta Red/70       White AA (L)
        600: "#EB425C",
        700: "#EA2541", // Nesta Red/100                      Black AA
        800: "#C61530", //                    White AA        Black AA (L)
        900: "#8D1124", //                    White AAA
        950: "#640D1A",
      },

      "orange": {
        DEFAULT: "#FF6E47",
        50: "#F1DCCA",
        100: "#F3D7C4",
        200: "#F3C9B0",
        300: "#EFB5A5", // Nesta Orange/40
        400: "#F5AF8E",
        500: "#FF997E", // Nesta Orange/70
        600: "#F98B66",
        700: "#FF6E47", // Nesta Orange/100                   Black AAA
        800: "#EC4109", //                    White AA (L)    Black AA
        900: "#A9370A", //                    White AA        Black AA (L)
        950: "#712A0A", //                    White AAA
      },

      "grey": {
        DEFAULT: "#646363",
        50: "#E3E3E3",
        100: "#D9D9D9",
        200: "#C7C7C7",
        300: "#B3B2B2", // Nesta Dark Grey/40
        400: "#9F9E9E", //                                    Black AAA
        500: "#8A8989", // Nesta Dark Grey/70
        600: "#777676", //                    White AA        Black AA
        700: "#646363", // Nesta Dark Grey/100
        800: "#4A4A4A", //                    White AAA
        900: "#333333",
        950: "#262626",
      },

      "navy": {
        DEFAULT: "#0F294A",
        50: "#EDEDEE",
        100: "#E4E5E7",
        200: "#D1D3D7",
        300: "#BABFC6", // Nesta Navy/20
        400: "#A5ACB6",
        500: "#8F99A7", // Nesta Navy/40                      Black AAA
        600: "#697A91", //                    White AA (L)    Black AA
        700: "#4E6178", // Nesta Navy/70      White AA
        800: "#264469", //                    White AAA
        900: "#0F294A", // Nesta Navy/100
        950: "#051A33",
      },

      "yellow": {
        DEFAULT: "#FDB633",
        50: "#FBF5E9",
        100: "#F9EBD2",
        200: "#F7E0B6",
        300: "#EED29D", // Nesta Yellow/40
        400: "#F7CE82",
        500: "#F5C368", // Nesta Yellow/70
        600: "#FABF52",
        700: "#FDB633", // Nesta Yellow/100
        800: "#DF9307", //                                    Black AAA
        900: "#926001", //                    White AA
        950: "#4C3201", //                    White AAA
      },

      "violet": {
        DEFAULT: "#A59BEE",
        50: "#F4F3FC",
        100: "#F0EFFB",
        200: "#E1DFF7",
        300: "#D6D2F4",
        400: "#CBC7E8", // Nesta Violet/40
        500: "#B7B1EB", // Nesta Violet/70
        600: "#A59BEE", // Nesta Violet/100                   Black AAA
        700: "#8A80E5", //                    White AA (L)    Black AA
        800: "#6C5FE2", //                    White AA        Black AA (L)
        900: "#3522DD", //                    White AAA
        950: "#1A107A"
      },

      "pink": {
        DEFAULT: "#F6A4B7",
        50: "#FCF3F5",
        100: "#F8E8EB",
        200: "#F2D9DF",
        300: "#EBCBD2", // Nesta Pink/40
        400: "#F0B7C4", // Nesta Pink/70
        500: "#F6A4B7", // Nesta Pink/100
        600: "#EA8FA4", //                                    Black AAA
        700: "#DC748D", //                    White AA (L)
        800: "#C85670", //                                    Black AA
        900: "#8F3D50", //                    White AAA
        950: "#5B333D"
      },

      "sand": {
        50: "#F6F4F2", // Nesta Sand/20
        100: "#EEEDEC",
        200: "#E5E3E1",
        300: "#DDD9D6", // Nesta Sand/40
        400: "#D7D1CA", // Nesta Sand/70
        500: "#D2C9C0", // Nesta Sand/100
        600: "#C0B5AA",
        700: "#ADA195", //                                    Black AAA
        800: "#938576", //                    White AA (L)    Black AA
        900: "#6A6158", //                    White AA        Black AA (L)
        950: "#4A4540", //                    White AAA
      },
    },
    extend: {
      fontFamily: {
        sans: ['Averta', ...defaultTheme.fontFamily.sans],
        title: ['Zosia', ...defaultTheme.fontFamily.sans],
      },
      spacing: {
        "inherit": "inherit",
        "0.75": "3px",
        "1.25": "5px",
      },
    },
  },
  plugins: [
    require('tailwindcss-unimportant'),
  ]
}
