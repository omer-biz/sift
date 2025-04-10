import "./app.css";
import * as seeder from "./interop/seeder.js";
import Dexie from "dexie";

const db = new Dexie("SiftDB");

async function getNotes(db, search = "", tagIds = []) {
  const cleanSearch = search.trim().toLowerCase();

  let notes = await db.notes
    .orderBy("updatedAt")
    .reverse()
    .filter((note) => {
      const matchesSearch =
        cleanSearch === "" ||
        note.title.toLowerCase().includes(cleanSearch) ||
        note.content.toLowerCase().includes(cleanSearch);

      const matchesTags =
        tagIds.length === 0 || tagIds.every((id) => note.tagIds.includes(id));

      return matchesSearch && matchesTags;
    })
    .toArray();

  const allTagIds = Array.from(new Set(notes.flatMap((n) => n.tagIds)));
  const allTags = await db.tags.bulkGet(allTagIds);
  const tagMap = new Map(allTagIds.map((id, i) => [id, allTags[i]]));

  return notes.map(({ tagIds, ...note }) => ({
    ...note,
    tags: tagIds.map((id) => tagMap.get(id)).filter(Boolean),
  }));
}

async function getTags(db) {
  return db.tags.toArray();
}

async function getPins(db) {
  return db.pins.toArray();
}

async function createPin(db, pinForm) {
  let pinId = await db.pins.add(pinForm);

  let pin = await db.pins.get(pinId);
  let tags = await db.tags.bulkGet(pin.tagIds);

  return { ...pin, tags: tags };
}

async function deletePin(db, pinId) {
  return db.pins.delete(pinId);
}

db.version(1).stores({
  notes: "++id, title, content, createdAt, updatedAt, tagIds",
  tags: "++id, name, color",
  pins: "++id, tagIds, searchQuery, noteCount",
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
    favorites: JSON.parse(localStorage.favorites || "[]"),
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
          let notes = await getNotes(db, data.search, data.tagIds);
          app.ports.recNotes.send(notes);
          return;

        case "GET_TAGS":
          let tags = await getTags(db);
          app.ports.recTags.send(tags);
          return;

        case "GET_PINS":
          // let pins = await getPins(db);
          // app.ports.recPins.send(pins);
          return;

        case "CREATE_PIN":
          let pin = await createPin(db, data);
          app.ports.recPin.send(pin);
          return;

        case "DELETE_PIN":
          let _ = await deletePin(db, data);
          return;

        case "SAVE_FAVORITES":
          console.log(JSON.stringify(data));
          localStorage.favorites = JSON.stringify(data);
          return;

        default:
          console.warn(`Unhandled outgoing port: "${tag}"`);
          return;
      }
    });
  }
};
