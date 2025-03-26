//import type { Config } from "tailwindcss";

export default {
    darkMode: "class",
    content: [
        "./src/**/*.{js,elm,ts,css,html}",
        "./.elm-land/**/*.{js,elm,ts,css,html}",
    ],
    theme: {
	extend: {
	    colors: {
		black: {
		    100: '#7c6f64',
		    200: '#665c54',
		    300: '#504945',
		    400: '#3c3836',
		    500: '#282828',
		    600: '#1d2021',
		},
		white: {
		    100: '#f9f5d7',
		    200: '#fbf1c7',
		    300: '#ebdbb2',
		    400: '#d5c4a1',
		    500: '#bdae93',
		    600: '#a89984',
		},
	        red: {
		    100: '#fb4934',
		    200: '#cc241d',
		    300: '#9d0006'
		},
		green: {
		    100: '#b8bb26',
		    200: '#98871a',
		    300: '#79750e'
		},
		yellow: {
		    100: '#fabd2f',
		    200: '#d79921',
		    300: '#b57614'
		},
		blue: {
		    100: '#83a598',
		    200: '#458588',
		    300: '#076678'
		},
		purple: {
		    100: '#d3869b',
		    200: '#b16286',
		    300: '#8f3f71'
		},
		aqua: {
		    100: '#8ec07c',
		    200: '#689d6a',
		    300: '#427b58'
		},
		orange: {
		    100: '#fe8019',
		    200: '#d65d0e',
		    300: '#af3a03'
		}
	    }
	}
    },
    plugins: [],
};

