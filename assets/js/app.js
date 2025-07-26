// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Define LiveView hooks
let Hooks = {}

// Flash auto-dismiss hook
Hooks.FlashAutoDismiss = {
  mounted() {
    const flashElement = this.el
    let timeoutId = null
    
    // Start auto-dismiss timer
    const startTimer = () => {
      timeoutId = setTimeout(() => {
        if (flashElement && flashElement.isConnected) {
          flashElement.click()
        }
      }, 5000)
    }
    
    // Start the initial timer
    startTimer()
    
    // Pause animation and timer on hover
    flashElement.addEventListener('mouseenter', () => {
      const progressBar = flashElement.querySelector('.flash-progress-bar')
      if (progressBar) {
        progressBar.style.animationPlayState = 'paused'
      }
      if (timeoutId) {
        clearTimeout(timeoutId)
        timeoutId = null
      }
    })
    
    // Resume animation and restart timer when mouse leaves
    flashElement.addEventListener('mouseleave', () => {
      const progressBar = flashElement.querySelector('.flash-progress-bar')
      if (progressBar) {
        progressBar.style.animationPlayState = 'running'
        // Calculate remaining time based on progress bar width
        const computedStyle = window.getComputedStyle(progressBar)
        const currentWidth = parseFloat(computedStyle.width)
        const parentWidth = parseFloat(window.getComputedStyle(progressBar.parentElement).width)
        const remainingPercentage = currentWidth / parentWidth
        const remainingTime = 5000 * remainingPercentage
        
        // Restart timer with remaining time
        timeoutId = setTimeout(() => {
          if (flashElement && flashElement.isConnected) {
            flashElement.click()
          }
        }, remainingTime)
      }
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

