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

async function getNote(db, noteId) {
  let note = await db.notes.get(parseInt(noteId));

  if (note != undefined) {
    let tags = await db.tags.bulkGet(note.tagIds);
    tags = tags.filter((t) => t != undefined);
    return { ...note, tags: tags };
  }

  return null;
}

async function saveNote(db, note) {
  let { id, ...n } = note;
  let noteId = await db.notes.update(note.id, n);
}

async function createNote(db, newNote) {
  let now = new Date().toISOString();
  return db.notes.add({ ...newNote, createdAt: now, updatedAt: now });
}

async function createTag(db, newTag) {
  const existing = await db.tags
    .where("[name+color]")
    .equals([newTag.name, newTag.color])
    .first();

  if (existing) {
    return existing;
  }

  const id = await db.tags.add(newTag);
  return { id, ...newTag };
}

async function deleteNote(db, noteId) {
  return db.notes.delete(noteId);
}

async function getTags(db, query) {
  let term = query.trim().toLowerCase();
  if (term.length != 0) {
    return db.tags
      .filter((tag) => {
        return (
          tag.name.toLowerCase().includes(term) ||
          tag.color.toLowerCase().includes(term)
        );
      })
      .toArray();
  }
  return db.tags.toArray();
}

async function getPins(db) {
  let pins = await db.pins.toArray();

  return Promise.all(
    pins.map(async (pin) => {
      let tags = await db.tags.bulkGet(pin.tagIds);

      return { ...pin, tags: tags };
    }),
  );
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

async function collectTags(db) {
  const tags = await db.tags.toArray();

  for (const tag of tags) {
    const count = await db.notes.where("tagIds").anyOf(tag.id).count();

    if (count === 0) {
      await db.tags.delete(tag.id);
    }
  }
}

db.version(1).stores({
  notes: "++id, title, content, createdAt, updatedAt, *tagIds",
  tags: "++id, [name+color]",
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
  };
};

export const onReady = ({ app, env }) => {
  collectTags(db);
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

        case "GET_NOTE":
          let note = await getNote(db, data);
          app.ports.recNote.send(note);
          return;

        case "SAVE_NOTE":
          await saveNote(db, data);
          app.ports.noteSaved.send(0);
          return;

        case "CREATE_NOTE":
          let noteId = await createNote(db, data);
          app.ports.noteSaved.send(noteId);
          return;

        case "DELETE_NOTE":
          await deleteNote(db, data);
          return;

        case "GET_TAGS":
          let tags = await getTags(db, data);
          app.ports.recTags.send(tags);
          return;

        case "CREATE_TAG":
          let tag = await createTag(db, data);
          app.ports.tagSaved.send(tag);
          return;

        case "GET_PINS":
          let pins = await getPins(db);
          app.ports.recPins.send(pins);
          return;

        case "CREATE_PIN":
          let pin = await createPin(db, data);
          app.ports.recPin.send(pin);
          return;

        case "DELETE_PIN":
          let _ = await deletePin(db, data);
          return;

        case "SAVE_FAVORITES":
          localStorage.favorites = JSON.stringify(data);
          return;

        default:
          console.warn(`Unhandled outgoing port: "${tag}"`);
          return;
      }
    });
  }
};
