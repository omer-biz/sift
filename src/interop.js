import "./app.css";
import * as seeder from "./interop/seeder.js";
import Dexie from "dexie";

const db = new Dexie("SiftDB");

function getNotes(db, search, tagIds) {}
async function getTags(db) {
  return db.tags.toArray();
}

db.version(1).stores({
  notes: "++id, title, content, createdAt, updatedAt, tagIds",
  tags: "++id, name, color",
});

let preferDarkMode = () =>
  localStorage.theme === "dark" ||
  (!("theme" in localStorage) &&
    window.matchMedia("(prefers-color-scheme: dark)").matches);

const toggleDarkMode = () =>
  document.documentElement.classList.toggle("dark", preferDarkMode());
toggleDarkMode();

export const flags = ({ env }) => {
  if (env.NODE_ENV === "development") {
    seeder.seed(db);
  }

  return {
    theme: localStorage.theme || null,
    status: window.navigator.onLine,
  };
};

export const onReady = ({ app, env }) => {
  if (app.ports && app.ports.outgoing) {
    app.ports.outgoing.subscribe(async ({ tag, data }) => {
      switch (tag) {
        case "SWITCH_THEME":
          if (data == "light" || data == "dark") localStorage.theme = data;
          else localStorage.removeItem("theme");
          toggleDarkMode();
          return;

        case "GET_NOTES":
          let notes = getNotes(db, data.search, data.tagIds);
          app.ports.receiveNotes.send(notes);
          return;

        case "GET_TAGS":
          let tags = await getTags(db);
          app.ports.receiveTags.send(tags);
          return;

        default:
          console.warn(`Unhandled outgoing port: "${tag}"`);
          return;
      }
    });
  }
};
