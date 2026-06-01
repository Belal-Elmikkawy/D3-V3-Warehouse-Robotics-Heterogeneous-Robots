;;; ============================================================
;;;  DOMAIN: warehouse-heterogeneous-time (PDDL+)
;;;  Introduces a process for transfer time and an event for failure.
;;; ============================================================

(define (domain warehouse-heterogeneous-time)

  (:requirements
    :typing
    :negative-preconditions
    :equality
    :time
    :continuous-effects
    :fluents
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

    (manip-free     ?r - manip-robot)
    (transport-free ?r - transport-robot)
    (gripper-empty  ?r - manip-robot)
    (platform-empty ?r - transport-robot)
    
    ;; New predicate to track active transfer
    (transferring ?m - manip-robot ?t - transport-robot ?p - package ?l - location)
  )

  (:functions
    ;; Tracks the progress of the transfer (0 to 100)
    (transfer-progress ?p - package)
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

  ;; ============================================================
  ;; START TRANSFER
  ;; Initiates the continuous transfer process between robots.
  ;; ============================================================
  (:action start-transfer
    :parameters (?m  - manip-robot ?tr - transport-robot ?p  - package ?l  - location)
    :precondition (and
      (manip-at      ?m  ?l)
      (transport-at  ?tr ?l)
      (manip-holding ?m  ?p)
      (platform-empty ?tr)
      (not (transferring ?m ?tr ?p ?l))
      (= (transfer-progress ?p) 0)
    )
    :effect (and
      (transferring ?m ?tr ?p ?l)
      (not (manip-free ?m))         ; Robots are busy during transfer
      (not (transport-free ?tr))
    )
  )

  ;; ============================================================
  ;; CONTINUOUS PROCESS
  ;; Progress increases steadily over time while transferring.
  ;; ============================================================
  (:process transfer-process
    :parameters (?m - manip-robot ?tr - transport-robot ?p - package ?l - location)
    :precondition (transferring ?m ?tr ?p ?l)
    :effect (increase (transfer-progress ?p) (* #t 10.0))
  )

  ;; ============================================================
  ;; FINISH TRANSFER (SUCCESS)
  ;; Requires careful timing: must execute when progress is 80-99.
  ;; ============================================================
  (:action finish-transfer
    :parameters (?m - manip-robot ?tr - transport-robot ?p - package ?l - location)
    :precondition (and
      (transferring ?m ?tr ?p ?l)
      (>= (transfer-progress ?p) 80)
      (<= (transfer-progress ?p) 99)
    )
    :effect (and
      (not (transferring ?m ?tr ?p ?l))
      (transport-carrying ?tr ?p)
      (not (manip-holding ?m  ?p))
      (gripper-empty  ?m)
      (not (platform-empty ?tr))
      (assign (transfer-progress ?p) 0)
      (manip-free ?m)
      (transport-free ?tr)
    )
  )

  ;; ============================================================
  ;; EVENT (TRANSFER FAILURE)
  ;; Triggers automatically if they wait too long (>100 progress).
  ;; The package is dropped on the floor and transfer fails.
  ;; ============================================================
  (:event transfer-timeout
    :parameters (?m - manip-robot ?tr - transport-robot ?p - package ?l - location)
    :precondition (and
      (transferring ?m ?tr ?p ?l)
      (>= (transfer-progress ?p) 100)
    )
    :effect (and
      (not (transferring ?m ?tr ?p ?l))
      (assign (transfer-progress ?p) 0)
      
      ;; Penalty: Package drops on the floor
      (not (manip-holding ?m ?p))
      (package-at ?p ?l)
      (gripper-empty ?m)
      
      ;; Robots become free to try picking it up again
      (manip-free ?m)
      (transport-free ?tr)
    )
  )
  
  (:action manip-unload-from-transport
    :parameters (?r  - manip-robot ?tr - transport-robot ?p  - package ?l  - location)
    :precondition (and
      (manip-at           ?r  ?l)
      (transport-at       ?tr ?l)
      (transport-carrying ?tr ?p)
      (gripper-empty      ?r)
      (manip-free ?r)
      (transport-free ?tr)
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
    )
    :effect (and
      (manip-at     ?r ?l2)
      (not (manip-at ?r ?l1))
    )
  )

  (:action transport-move
    :parameters (?r  - transport-robot ?l1 - location ?l2 - location)
    :precondition (and
      (transport-at  ?r ?l1)
      (connected ?l1 ?l2)
      (transport-free ?r)
    )
    :effect (and
      (transport-at     ?r ?l2)
      (not (transport-at ?r ?l1))
    )
  )

)
