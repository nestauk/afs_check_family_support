import * as Turbo from '@hotwired/turbo'
import Alpine from 'alpinejs'
import focus from '@alpinejs/focus'
import './application.css'

Turbo.setFormMode("optin")
//Turbo.start()

Alpine.plugin(focus)
window.Alpine = Alpine
Alpine.start();

window.csrfToken = document.getElementsByName('csrf-token')[0].content
