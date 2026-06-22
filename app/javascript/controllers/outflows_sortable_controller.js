import { Controller } from "@hotwired/stimulus";

// Drag-to-reorder for the homepage Outflows breakdown list. Order is saved
// per-user via the same dashboard preferences endpoint used for section
// ordering, under the "outflows_category_order" key.
export default class extends Controller {
  static targets = ["section"];

  static values = {
    holdDelay: { type: Number, default: 800 },
  };

  connect() {
    this.draggedElement = null;
    this.touchStartX = 0;
    this.touchStartY = 0;
    this.currentTouchX = 0;
    this.currentTouchY = 0;
    this.isTouching = false;
    this.pendingSection = null;
    this.keyboardGrabbedElement = null;
    this.holdTimer = null;
    this.holdActivated = false;
  }

  // ===== Mouse Drag Events =====
  dragStart(event) {
    if (this.isTouching || this.pendingSection) {
      event.preventDefault();
      return;
    }

    this.draggedElement = event.currentTarget;
    this.draggedElement.classList.add("opacity-50");
    this.draggedElement.setAttribute("aria-grabbed", "true");
    event.dataTransfer.effectAllowed = "move";
  }

  dragEnd(event) {
    event.currentTarget.classList.remove("opacity-50");
    event.currentTarget.setAttribute("aria-grabbed", "false");
    this.clearPlaceholders();
  }

  dragOver(event) {
    event.preventDefault();
    event.dataTransfer.dropEffect = "move";

    const afterElement = this.getDragAfterElement(event.clientY);
    this.clearPlaceholders();

    if (afterElement == null) {
      this.showPlaceholder(this.lastSection(), "after");
    } else {
      this.showPlaceholder(afterElement, "before");
    }
  }

  drop(event) {
    event.preventDefault();
    event.stopPropagation();

    const afterElement = this.getDragAfterElement(event.clientY);
    this.moveDraggedElement(afterElement);

    this.clearPlaceholders();
    this.saveOrder();
  }

  // ===== Touch Events (bound to the drag handle) =====
  touchStart(event) {
    const section = event.currentTarget.closest(
      "[data-outflows-sortable-target='section']",
    );
    if (!section) return;

    this.pendingSection = section;
    this.touchStartX = event.touches[0].clientX;
    this.touchStartY = event.touches[0].clientY;
    this.currentTouchX = this.touchStartX;
    this.currentTouchY = this.touchStartY;
    this.holdActivated = false;

    section.style.userSelect = "none";
    section.style.webkitUserSelect = "none";

    this.holdTimer = setTimeout(() => {
      this.activateDrag();
    }, this.holdDelayValue);
  }

  activateDrag() {
    if (!this.pendingSection) return;

    this.holdActivated = true;
    this.isTouching = true;
    this.draggedElement = this.pendingSection;
    this.draggedElement.classList.add("opacity-50", "scale-[1.02]");
    this.draggedElement.setAttribute("aria-grabbed", "true");

    if (navigator.vibrate) {
      navigator.vibrate(30);
    }
  }

  touchMove(event) {
    const touchX = event.touches[0].clientX;
    const touchY = event.touches[0].clientY;

    if (!this.holdActivated) {
      const dx = touchX - this.touchStartX;
      const dy = touchY - this.touchStartY;
      if (dx * dx + dy * dy > 100) {
        this.cancelHold();
      }
      return;
    }

    if (!this.isTouching || !this.draggedElement) return;

    event.preventDefault();
    this.currentTouchX = touchX;
    this.currentTouchY = touchY;

    const afterElement = this.getDragAfterElement(this.currentTouchY);
    this.clearPlaceholders();

    if (afterElement == null) {
      this.showPlaceholder(this.lastSection(), "after");
    } else {
      this.showPlaceholder(afterElement, "before");
    }
  }

  touchEnd() {
    this.cancelHold();

    if (!this.holdActivated || !this.isTouching || !this.draggedElement) {
      this.resetTouchState();
      return;
    }

    const afterElement = this.getDragAfterElement(this.currentTouchY);
    this.moveDraggedElement(afterElement);

    this.draggedElement.classList.remove("opacity-50", "scale-[1.02]");
    this.draggedElement.setAttribute("aria-grabbed", "false");
    this.clearPlaceholders();
    this.saveOrder();

    this.resetTouchState();
  }

  cancelHold() {
    if (this.holdTimer) {
      clearTimeout(this.holdTimer);
      this.holdTimer = null;
    }
  }

  resetTouchState() {
    if (this.pendingSection) {
      this.pendingSection.style.userSelect = "";
      this.pendingSection.style.webkitUserSelect = "";
    }
    if (this.draggedElement) {
      this.draggedElement.style.userSelect = "";
      this.draggedElement.style.webkitUserSelect = "";
    }

    this.isTouching = false;
    this.draggedElement = null;
    this.pendingSection = null;
    this.holdActivated = false;
  }

  // ===== Keyboard Navigation =====
  handleKeyDown(event) {
    const currentSection = event.currentTarget;

    switch (event.key) {
      case "ArrowUp":
        event.preventDefault();
        if (this.keyboardGrabbedElement === currentSection) {
          this.moveUp(currentSection);
        }
        break;
      case "ArrowDown":
        event.preventDefault();
        if (this.keyboardGrabbedElement === currentSection) {
          this.moveDown(currentSection);
        }
        break;
      case "Enter":
      case " ":
        event.preventDefault();
        this.toggleGrabMode(currentSection);
        break;
      case "Escape":
        if (this.keyboardGrabbedElement) {
          event.preventDefault();
          this.releaseKeyboardGrab();
        }
        break;
    }
  }

  toggleGrabMode(section) {
    if (this.keyboardGrabbedElement === section) {
      this.releaseKeyboardGrab();
    } else {
      this.grabWithKeyboard(section);
    }
  }

  grabWithKeyboard(section) {
    if (this.keyboardGrabbedElement) {
      this.releaseKeyboardGrab();
    }

    this.keyboardGrabbedElement = section;
    section.setAttribute("aria-grabbed", "true");
    section.classList.add("ring-2", "ring-primary", "ring-offset-2");
  }

  releaseKeyboardGrab() {
    if (this.keyboardGrabbedElement) {
      this.keyboardGrabbedElement.setAttribute("aria-grabbed", "false");
      this.keyboardGrabbedElement.classList.remove(
        "ring-2",
        "ring-primary",
        "ring-offset-2",
      );
      this.keyboardGrabbedElement = null;
      this.saveOrder();
    }
  }

  moveUp(section) {
    const previousSibling = section.previousElementSibling;
    if (previousSibling?.hasAttribute("data-section-key")) {
      this.element.insertBefore(section, previousSibling);
      section.focus();
    }
  }

  moveDown(section) {
    const nextSibling = section.nextElementSibling;
    if (nextSibling?.hasAttribute("data-section-key")) {
      this.element.insertBefore(nextSibling, section);
      section.focus();
    }
  }

  // ===== Shared helpers =====
  moveDraggedElement(afterElement) {
    if (afterElement == null) {
      this.element.appendChild(this.draggedElement);
    } else {
      this.element.insertBefore(this.draggedElement, afterElement);
    }
  }

  lastSection() {
    const sections = this.sectionTargets;
    return sections[sections.length - 1] || null;
  }

  getDragAfterElement(pointerY) {
    const draggableElements = this.sectionTargets.filter(
      (section) => section !== this.draggedElement,
    );

    if (draggableElements.length === 0) return null;

    let closest = null;
    let minDistance = Number.POSITIVE_INFINITY;

    draggableElements.forEach((child) => {
      const rect = child.getBoundingClientRect();
      const centerY = rect.top + rect.height / 2;
      const distance = Math.abs(pointerY - centerY);

      if (distance < minDistance) {
        minDistance = distance;
        closest = child;
      }
    });

    return closest;
  }

  showPlaceholder(element, position) {
    if (!element) return;

    if (position === "before") {
      element.classList.add("border-t-4", "border-primary");
    } else {
      element.classList.add("border-b-4", "border-primary");
    }
  }

  clearPlaceholders() {
    this.sectionTargets.forEach((section) => {
      section.classList.remove("border-t-4", "border-b-4", "border-primary");
    });
  }

  async saveOrder() {
    const order = this.sectionTargets.map(
      (section) => section.dataset.sectionKey,
    );

    const csrfToken = document.querySelector('meta[name="csrf-token"]');
    if (!csrfToken) {
      console.error(
        "[Outflows Sortable] CSRF token not found. Cannot save category order.",
      );
      return;
    }

    try {
      const response = await fetch("/dashboard/preferences", {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken.content,
        },
        body: JSON.stringify({ preferences: { outflows_category_order: order } }),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        console.error(
          "[Outflows Sortable] Failed to save category order:",
          response.status,
          errorData,
        );
      }
    } catch (error) {
      console.error(
        "[Outflows Sortable] Network error saving category order:",
        error,
      );
    }
  }
}
