import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

// Registered once, app-wide. Import `gsap` from this module (not directly
// from 'gsap') anywhere plugins are needed, so registration always runs
// before use.
gsap.registerPlugin(ScrollTrigger)

export { gsap, ScrollTrigger }
