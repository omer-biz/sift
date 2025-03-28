import "./app.css";

let preferDarkMode = () =>
    localStorage.theme === "dark" ||
    (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches);

const toggleDarkMode = () =>
    document.documentElement.classList.toggle("dark", preferDarkMode());
toggleDarkMode();

export const flags = ({ env }) => {
    return {
        theme: localStorage.theme || null,
        status: window.navigator.onLine,
    };
};

export const onReady = ({ app, env }) => {
    if (app.ports && app.ports.outgoing) {
        app.ports.outgoing.subscribe(({ tag, data }) => {
            switch (tag) {
                case "SWITCH_THEME":
                    if (data == "light" || data == "dark")
                        localStorage.theme = data;
                    else localStorage.removeItem("theme");
                    toggleDarkMode();
                    return;

                default:
                    console.warn(`Unhandled outgoing port: "${tag}"`);
                    return;
            }
        });
    }
};
