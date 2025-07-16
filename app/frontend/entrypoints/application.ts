import ahoy from "ahoy.js";
import Alpine from "alpinejs";
import collapse from "@alpinejs/collapse";
import focus from "@alpinejs/focus";
import persist from "@alpinejs/persist";
import "./application.css";
import "@hotwired/turbo-rails";

window.ahoy = ahoy;

Alpine.plugin(collapse);
Alpine.plugin(focus);
Alpine.plugin(persist);

// Add magic method to easily be able to post data to the backend
Alpine.magic("post", (el, { Alpine }) => {
  return (url, data) =>
    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        authenticity_token: window.csrfToken,
        ...data,
      }),
    });
});

window.Alpine = Alpine;
Alpine.start();

window.csrfToken = document.querySelector("meta[name=csrf-token]").content;
