import { Controller } from "@hotwired/stimulus";

// Toggles the visibility of a category's subcategory rows in the
// dashboard "Categories" widget without affecting the row's own
// link-to-transactions click target.
export default class extends Controller {
  static targets = ["content", "chevron"];

  toggle(event) {
    event.preventDefault();
    event.stopPropagation();
    this.contentTarget.classList.toggle("hidden");
    this.chevronTarget.classList.toggle("rotate-180");
  }
}
