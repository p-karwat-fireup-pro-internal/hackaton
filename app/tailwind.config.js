const { tokens } = require("./src/design/tokens");

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./App.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: tokens.colors,
      fontWeight: tokens.fontWeight,
      letterSpacing: tokens.letterSpacing,
      spacing: tokens.spacing,
      borderRadius: tokens.borderRadius,
    },
  },
  plugins: [],
};
