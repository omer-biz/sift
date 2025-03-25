import type { Config } from "tailwindcss";

export default {
    darkMode: "class",
    content: [
        "./src/**/*.{js,elm,ts,css,html}",
        "./.elm-land/**/*.{js,elm,ts,css,html}",
    ],
    theme: {
        extend: {},
    },
    plugins: [],
} as Config;

