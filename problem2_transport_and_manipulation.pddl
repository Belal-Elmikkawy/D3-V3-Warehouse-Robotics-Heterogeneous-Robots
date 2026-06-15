;;; ============================================================
;;;  PROBLEM 2: Requires Transport and Manipulation Cooperation
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
    (manip-at       manip1        zone-A)
    (occupied       zone-A)      
    (manip-free     manip1)
    (gripper-empty  manip1)

    (manip-at       manip2        zone-C)
    (occupied       zone-C)     
    (manip-free     manip2)
    (gripper-empty  manip2)

    (transport-at   transport1    handoff-point)
    (occupied       handoff-point)
    (transport-free transport1)
    (platform-empty transport1)

    (package-at     package-1     zone-A)

    (connected zone-A        handoff-point)
    (connected handoff-point zone-A)
    (connected handoff-point zone-B)
    (connected zone-B        handoff-point)
    (connected zone-B        zone-C)
    (connected zone-C        zone-B)

    (transit-area handoff-point)
    (transit-area zone-B)
  )
  (:goal
    (and
      (package-at package-1 zone-C)
    )
  )
)