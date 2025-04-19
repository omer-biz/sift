import EasyMDE from "easymde";

class ContentEditor extends HTMLElement {
  constructor() {
    super();
    this._editorValue = "";
  }

  static get observedAttributes() {
    return ["value"];
  }

  get editorValue() {
    return this._editorValue;
  }

  set editorValue(value) {
    if (this._editorValue === value) return;
    this._editorValue = value;

    if (!this._editor) return;
    this._editor.value(value);
  }

  updateTheme() {
    const easyMDEContainer = this.shadowRoot.querySelector(".EasyMDEContainer");

    easyMDEContainer.classList.toggle(
      "dark-mode",
      localStorage.theme === "dark",
    );
  }

  connectedCallback() {
    const shadow = this.attachShadow({ mode: "open" });

    shadow.innerHTML = `<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/easymde/dist/easymde.min.css" />
${editorStyle}
`;

    const textArea = document.createElement("textarea");
    textArea.setAttribute("id", "editor");
    shadow.appendChild(textArea);

    this._editor = new EasyMDE({
      element: textArea,
      toolbar: false,
      status: false,
      initialValue: this._editorValue,
    });

    this._editor.codemirror.on("change", (cm) => {
      this._editorValue = cm.getValue();
      this.dispatchEvent(new CustomEvent("editorChanged"));
    });

    this.updateTheme();
  }
}

customElements.define("content-editor", ContentEditor);

const editorStyle = `
<style>
/* Gruvbox Light Theme */
.EasyMDEContainer {
  --bg: #fbf1c7; /* Background */
  --fg0: #282828; /* Foreground 0 */
  --fg1: #3c3836; /* Foreground 1 */
  --fg4: #a89984; /* Foreground 4 */
  --orange: #d65d0e;
  --yellow: #fabd2f;
  --green: #b8bb26;
  --aqua: #8ec07c;
  --blue: #83a598;
  --purple: #d3869b;
  --red: #fb4934;
}

.EasyMDEContainer.dark-mode {
  /* Gruvbox Dark Theme */
  --bg: #282828; /* Background */
  --fg0: #fbf1c7; /* Foreground 0 */
  --fg1: #ebdbb2; /* Foreground 1 */
  --fg4: #a89984; /* Foreground 4 */
  --orange: #fe8019;
  --yellow: #fabd2f;
  --green: #b8bb26;
  --aqua: #8ec07c;
  --blue: #83a598;
  --purple: #d3869b;
  --red: #fb4934;
}

.EasyMDEContainer {
  background-color: var(--bg);
  color: var(--fg0);
}

.EasyMDEContainer .editor-toolbar {
  background-color: var(--bg);
  color: var(--fg1);
}

.EasyMDEContainer .editor-toolbar a {
  color: var(--fg1);
}

.EasyMDEContainer .editor-toolbar a:hover {
  color: var(--orange);
}

.EasyMDEContainer .editor-toolbar button {
  color: var(--fg1);
  background-color: transparent;
}

.EasyMDEContainer .editor-toolbar button:hover {
  color: var(--orange);
}

.EasyMDEContainer .editor-toolbar button.active {
  color: var(--green);
}

.EasyMDEContainer .CodeMirror {
  background-color: var(--bg);
  color: var(--fg0);
  border: none;
}

.EasyMDEContainer .CodeMirror-cursor {
}

.EasyMDEContainer .CodeMirror-selected {
  background-color: rgba(var(--blue), 0.3); /* Adjust alpha for selection highlight */
}

.EasyMDEContainer .cm-s-easymde span.cm-header {
  color: var(--blue);
}

.EasyMDEContainer .cm-s-easymde span.cm-quote {
  color: var(--aqua);
  font-style: italic;
}

.EasyMDEContainer .cm-s-easymde span.cm-strong {
  color: var(--yellow);
  font-weight: bold;
}

.EasyMDEContainer .cm-s-easymde span.cm-em {
  color: var(--purple);
  font-style: italic;
}

.EasyMDEContainer .cm-s-easymde span.cm-link {
  color: var(--green);
  text-decoration: underline;
}

.EasyMDEContainer .cm-s-easymde span.cm-code {
  background-color: rgba(var(--fg4), 0.1);
  color: var(--orange);
  font-family: monospace;
}

.EasyMDEContainer .cm-s-easymde span.cm-hr {
}

.EasyMDEContainer .editor-preview-side,
.EasyMDEContainer .editor-preview {
  background-color: var(--bg);
  color: var(--fg1);
}

.EasyMDEContainer .editor-preview h1,
.EasyMDEContainer .editor-preview h2,
.EasyMDEContainer .editor-preview h3,
.EasyMDEContainer .editor-preview h4,
.EasyMDEContainer .editor-preview h5,
.EasyMDEContainer .editor-preview h6 {
  color: var(--blue);
}

.EasyMDEContainer .editor-preview blockquote {
  color: var(--aqua);
  margin-left: 0;
  padding-left: 1em;
  font-style: italic;
}

.EasyMDEContainer .editor-preview strong {
  color: var(--yellow);
}

.EasyMDEContainer .editor-preview em {
  color: var(--purple);
}

.EasyMDEContainer .editor-preview a {
  color: var(--green);
}

.EasyMDEContainer .editor-preview code {
  background-color: rgba(var(--fg4), 0.1);
  color: var(--orange);
  font-family: monospace;
  padding: 0.2em 0.4em;
}

.EasyMDEContainer .editor-preview hr {
}

/* For lists in preview */
.EasyMDEContainer .editor-preview ul,
.EasyMDEContainer .editor-preview ol {
  color: var(--fg1);
}

/* Styling for the fullscreen mode */
.EasyMDEContainer.fullscreen {
  background-color: var(--bg);
  color: var(--fg0);
}

.EasyMDEContainer.fullscreen .editor-toolbar {
  background-color: var(--bg);
  color: var(--fg1);
}

.EasyMDEContainer.fullscreen .CodeMirror {
  background-color: var(--bg);
  color: var(--fg0);
}

.EasyMDEContainer.fullscreen .editor-preview-side,
.EasyMDEContainer.fullscreen .editor-preview {
  background-color: var(--bg);
  color: var(--fg1);
}

</style>
`;
