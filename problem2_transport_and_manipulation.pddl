;;; ============================================================
;;;  PROBLEM 2: Long-distance delivery — cooperation required
;;;
;;;  Layout:
;;;    [zone-A] -- [handoff-point] -- [zone-B] -- [zone-C]
;;;
;;;  manip1 starts at zone-A (picks up the package)
;;;  transport1 starts at handoff-point (carries it to zone-C)
;;;  manip2 starts at zone-C (unloads and places at destination)
;;;
;;;  A manip-robot CANNOT reach zone-C alone in time
;;;  (it would need to cross the warehouse — cooperation is needed).
;;; ============================================================

(define (problem cooperative-delivery)
  (:domain warehouse-heterogeneous)

  (:objects
    zone-A handoff-point zone-B zone-C - location
    package-1                          - package
    manip1                             - manip-robot
    manip2                             - manip-robot
    transport1                         - transport-robot
  )

  (:init
    ;; --- robot starting positions ---
    (robot-at     manip1     zone-A)
    (robot-at     manip2     zone-C)
    (robot-at     transport1 zone-A)   ; transport starts with manip1

    ;; --- robot availability ---
    (robot-free     manip1)
    (robot-free     manip2)
    (robot-free     transport1)
    (gripper-empty  manip1)
    (gripper-empty  manip2)
    (platform-empty transport1)

    ;; --- package starting state ---
    (package-at   package-1  zone-A)

    ;; --- warehouse map ---
    (connected zone-A        handoff-point)
    (connected handoff-point zone-A)
    (connected handoff-point zone-B)
    (connected zone-B        handoff-point)
    (connected zone-B        zone-C)
    (connected zone-C        zone-B)

    ;; --- transit areas (manip-robots cannot enter these) ---
    (transit-area handoff-point)
    (transit-area zone-B)
  )

  ;; GOAL: package-1 is at zone-C (far destination)
  (:goal
    (and
      (package-at package-1 zone-C)
    )
  )
)