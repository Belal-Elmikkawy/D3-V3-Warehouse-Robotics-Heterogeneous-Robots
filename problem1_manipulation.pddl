;;; ============================================================
;;;  PROBLEM 1: Short-distance task
;;; ============================================================

(define (problem single-robot-delivery)
  (:domain warehouse-heterogeneous)
  (:objects
    shelf-A shelf-B corridor - location
    package-1               - package
    manip1                  - manip-robot
  )
  (:init
    (manip-at     manip1    shelf-A)
    (occupied     shelf-A)
    (manip-free   manip1)
    (gripper-empty manip1)
    (package-at   package-1 shelf-A)

    (connected    shelf-A   corridor)
    (connected    corridor  shelf-A)
    (connected    corridor  shelf-B)
    (connected    shelf-B   corridor)
  )
  (:goal
    (and
      (package-at package-1 shelf-B)
    )
  )
)