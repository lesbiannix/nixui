/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app.nix",
    "./../../src/**/*.nix",
  ],
  theme: {
    extend: {
      animation: {
        'gradient': 'gradient-shift 3s ease infinite',
      },
      backdropBlur: {
        xs: '2px',
      }
    },
  },
  plugins: [],
}