import Alpine from 'alpinejs'
import collapse from '@alpinejs/collapse'
import focus from '@alpinejs/focus'
import persist from '@alpinejs/persist'
import './application.css'

Alpine.plugin(collapse)
Alpine.plugin(focus)
Alpine.plugin(persist)
window.Alpine = Alpine
Alpine.start();

window.csrfToken = document.getElementsByName('csrf-token')[0].content
