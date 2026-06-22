import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="command-palette"
export default class extends Controller {
  static targets = ["dialog", "input", "form", "results"];

  open(event) {
    event?.preventDefault();
    if (this.dialogTarget.open) return;

    this.dialogTarget.showModal();
    this.inputTarget.value = "";
    this.formTarget.requestSubmit();
  }

  close() {
    if (this.dialogTarget.open) this.dialogTarget.close();
  }

  navigate(event) {
    const links = this.#resultLinks();
    if (links.length === 0) return;

    if (event.key === "ArrowDown") {
      event.preventDefault();
      this.#focusLink(links, this.#currentIndex(links) + 1);
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      this.#focusLink(links, this.#currentIndex(links) - 1);
    } else if (event.key === "Enter" && this.#currentIndex(links) === -1) {
      event.preventDefault();
      links[0].click();
    }
  }

  #resultLinks() {
    return Array.from(
      this.element.querySelectorAll('[data-command-palette-target="resultLink"]'),
    );
  }

  #currentIndex(links) {
    return links.indexOf(document.activeElement);
  }

  #focusLink(links, index) {
    const clamped = Math.max(0, Math.min(index, links.length - 1));
    links[clamped]?.focus();
  }
}
