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

  ;; ----------------------------------------------------------
  ;;  TYPES
  ;; ----------------------------------------------------------
  (:types
    location              ; named places in the warehouse
    package               ; items to be delivered
    robot                 ; base type (never used directly)
    transport-robot       ; fast, no manipulation capability
    manip-robot           ; slower, full manipulation capability
    - robot               ; both subtypes inherit from robot
  )

  ;; ----------------------------------------------------------
  ;;  PREDICATES
  ;;  We model location, holding, surface state, and capability
  ;;  explicitly so the planner cannot cheat.
  ;; ----------------------------------------------------------
  (:predicates

    ;; --- positional facts ---
    (robot-at       ?r - robot    ?l - location)
    (package-at     ?p - package  ?l - location)

    ;; --- holding facts ---
    ;; Only a manip-robot can hold a package in its gripper
    (manip-holding  ?r - manip-robot    ?p - package)
    ;; A transport-robot carries packages loaded onto its platform
    (transport-carrying ?r - transport-robot ?p - package)

    ;; --- surface / staging area state ---
    ;; A staging point is a location where a package sits waiting
    ;; to be picked up by a transport robot (placed there by manip)
    (package-staged ?p - package ?l - location)

    ;; --- adjacency / reachability ---
    (connected      ?l1 - location ?l2 - location)
    (transit-area   ?l - location)  ; Only transport-robots can enter these areas

    ;; --- robot availability ---
    (robot-free     ?r - robot)           ; robot has no current task
    (gripper-empty  ?r - manip-robot)     ; manip-robot gripper is free
    (platform-empty ?r - transport-robot) ; transport platform is free
  )

  ;; ============================================================
  ;;  ACTIONS — MANIPULATION ROBOT
  ;;  These actions are ONLY available to manip-robot instances.
  ;;  A transport-robot cannot use them (type system enforces this).
  ;; ============================================================

  ;; --- manip-robot picks a package off the floor/shelf ---
  (:action manip-pick-up
    :parameters (?r - manip-robot
                 ?p - package
                 ?l - location)
    :precondition (and
      (robot-at       ?r ?l)       ; robot is at same location
      (package-at     ?p ?l)       ; package is at that location
      (gripper-empty  ?r)          ; gripper must be free first
      (robot-free     ?r)
    )
    :effect (and
      (manip-holding  ?r ?p)       ; robot now grips package
      (not (package-at ?p ?l))     ; package leaves the floor
      (not (gripper-empty ?r))     ; gripper is now occupied
    )
  )

  ;; --- manip-robot places a package on the floor ---
  (:action manip-put-down
    :parameters (?r - manip-robot
                 ?p - package
                 ?l - location)
    :precondition (and
      (robot-at      ?r ?l)
      (manip-holding ?r ?p)
    )
    :effect (and
      (package-at    ?p ?l)        ; package returned to floor
      (not (manip-holding ?r ?p))
      (gripper-empty ?r)
    )
  )

  ;; --- manip-robot STAGES a package on the transport platform ---
  ;;  This is the KEY cooperation action: manip loads onto transport
  (:action manip-load-onto-transport
    :parameters (?r  - manip-robot
                 ?tr - transport-robot
                 ?p  - package
                 ?l  - location)
    :precondition (and
      (robot-at      ?r  ?l)       ; both robots at same location
      (robot-at      ?tr ?l)
      (manip-holding ?r  ?p)       ; manip is holding the package
      (platform-empty ?tr)         ; transport platform must be free
    )
    :effect (and
      (transport-carrying ?tr ?p)  ; package is now on transport
      (not (manip-holding ?r  ?p))
      (gripper-empty  ?r)
      (not (platform-empty ?tr))
    )
  )

  ;; --- manip-robot UNLOADS a package from the transport platform ---
  (:action manip-unload-from-transport
    :parameters (?r  - manip-robot
                 ?tr - transport-robot
                 ?p  - package
                 ?l  - location)
    :precondition (and
      (robot-at           ?r  ?l)
      (robot-at           ?tr ?l)
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

  ;; --- manip-robot moves (slower: one step at a time) ---
  (:action manip-move
    :parameters (?r  - manip-robot
                 ?l1 - location
                 ?l2 - location)
    :precondition (and
      (robot-at   ?r ?l1)
      (connected  ?l1 ?l2)
      (robot-free ?r)
      (not (transit-area ?l2))
    )
    :effect (and
      (robot-at     ?r ?l2)
      (not (robot-at ?r ?l1))
    )
  )

  ;; ============================================================
  ;;  ACTIONS — TRANSPORT ROBOT
  ;;  These actions are ONLY available to transport-robot instances.
  ;;  A manip-robot cannot use them.
  ;; ============================================================

  ;; --- transport-robot moves (fast: no manipulation, just travel) ---
  (:action transport-move
    :parameters (?r  - transport-robot
                 ?l1 - location
                 ?l2 - location)
    :precondition (and
      (robot-at  ?r ?l1)
      (connected ?l1 ?l2)
      (robot-free ?r)
    )
    :effect (and
      (robot-at     ?r ?l2)
      (not (robot-at ?r ?l1))
    )
  )

  ;; --- transport-robot delivers a package (drops on platform) ---
  ;;  Note: the transport robot CANNOT pick up packages itself.
  ;;  It can only set down what was loaded onto it by a manip-robot.
  (:action transport-deposit
    :parameters (?r - transport-robot
                 ?p - package
                 ?l - location)
    :precondition (and
      (robot-at           ?r ?l)
      (transport-carrying ?r ?p)
    )
    :effect (and
      (package-staged ?p ?l)           ; package waits at destination
      (not (transport-carrying ?r ?p))
      (platform-empty ?r)
    )
  )
)