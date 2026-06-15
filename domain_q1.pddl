;;; ============================================================
;;;  DOMAIN: warehouse-heterogeneous
;;;  Robots have different capabilities:
;;;    - transport-robot : can move fast, cannot manipulate
;;;    - manip-robot     : can pick/place, moves slower
;;;  Cooperation is required for full delivery tasks.
;;; ============================================================

(define (domain warehouse-heterogeneous)

  (:requirements
    :typing
    :negative-preconditions
    :equality
  )

  (:types
    location
    package
    transport-robot
    manip-robot
  )

  (:predicates
    (manip-at       ?r - manip-robot    ?l - location)
    (transport-at   ?r - transport-robot ?l - location)
    (package-at     ?p - package  ?l - location)

    (manip-holding  ?r - manip-robot    ?p - package)
    (transport-carrying ?r - transport-robot ?p - package)
    (package-staged ?p - package ?l - location)

    (connected      ?l1 - location ?l2 - location)
    (transit-area   ?l - location)
    
    ;; Added for Multi-Agent Mutual Exclusion
    (occupied       ?l - location)

    (manip-free     ?r - manip-robot)
    (transport-free ?r - transport-robot)
    (gripper-empty  ?r - manip-robot)
    (platform-empty ?r - transport-robot)
  )

  (:action manip-pick-up
    :parameters (?r - manip-robot ?p - package ?l - location)
    :precondition (and
      (manip-at       ?r ?l)
      (package-at     ?p ?l)
      (gripper-empty  ?r)
      (manip-free     ?r)
    )
    :effect (and
      (manip-holding  ?r ?p)
      (not (package-at ?p ?l))
      (not (gripper-empty ?r))
    )
  )

  (:action manip-put-down
    :parameters (?r - manip-robot ?p - package ?l - location)
    :precondition (and
      (manip-at      ?r ?l)
      (manip-holding ?r ?p)
    )
    :effect (and
      (package-at    ?p ?l)
      (not (manip-holding ?r ?p))
      (gripper-empty ?r)
    )
  )

  (:action manip-load-onto-transport
    :parameters (?r  - manip-robot
                 ?tr - transport-robot
                 ?p  - package
                 ?l1 - location
                 ?l2 - location)
    :precondition (and
      (manip-at      ?r  ?l1)
      (transport-at  ?tr ?l2)
      (connected     ?l1 ?l2)
      (manip-holding ?r  ?p)
      (platform-empty ?tr)
    )
    :effect (and
      (transport-carrying ?tr ?p)
      (not (manip-holding ?r  ?p))
      (gripper-empty  ?r)
      (not (platform-empty ?tr))
    )
  )

  (:action manip-unload-from-transport
    :parameters (?r  - manip-robot
                 ?tr - transport-robot
                 ?p  - package
                 ?l1 - location
                 ?l2 - location)
    :precondition (and
      (manip-at           ?r  ?l1)
      (transport-at       ?tr ?l2)
      (connected          ?l1 ?l2)
      (transport-carrying ?tr ?p)
      (gripper-empty      ?r)
    )
    :effect (and
      (manip-holding      ?r  ?p)
      (not (transport-carrying ?tr ?p))
      (platform-empty     ?tr)
      (not (gripper-empty ?r))
    )
  )

  (:action manip-move
    :parameters (?r  - manip-robot ?l1 - location ?l2 - location)
    :precondition (and
      (manip-at   ?r ?l1)
      (connected  ?l1 ?l2)
      (manip-free ?r)
      (not (transit-area ?l2))
      (not (occupied ?l2)) ; Ensures location is physically free
    )
    :effect (and
      (manip-at     ?r ?l2)
      (not (manip-at ?r ?l1))
      (occupied     ?l2)
      (not (occupied ?l1))
    )
  )

  (:action transport-move
    :parameters (?r  - transport-robot ?l1 - location ?l2 - location)
    :precondition (and
      (transport-at  ?r ?l1)
      (connected ?l1 ?l2)
      (transport-free ?r)
      (not (occupied ?l2)) ; Ensures location is physically free
    )
    :effect (and
      (transport-at     ?r ?l2)
      (not (transport-at ?r ?l1))
      (occupied     ?l2)
      (not (occupied ?l1))
    )
  )

  (:action transport-deposit
    :parameters (?r - transport-robot ?p - package ?l - location)
    :precondition (and
      (transport-at       ?r ?l)
      (transport-carrying ?r ?p)
    )
    :effect (and
      (package-staged ?p ?l)
      (not (transport-carrying ?r ?p))
      (platform-empty ?r)
    )
  )
)