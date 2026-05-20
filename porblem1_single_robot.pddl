;;; ============================================================
;;;  PROBLEM 1: Short-distance task — manip-robot can do it alone
;;;  Layout:  [shelf-A] -- [corridor] -- [shelf-B]
;;;  Goal: move package-1 from shelf-A to shelf-B
;;;  One manip-robot can pick, walk, and place it.
;;; ============================================================

(define (problem single-robot-delivery)
  (:domain warehouse-heterogeneous)

  (:objects
    shelf-A shelf-B corridor - location
    package-1               - package
    manip1                  - manip-robot
  )

  (:init
    ;; --- robot starting state ---
    (robot-at     manip1    shelf-A)
    (robot-free   manip1)
    (gripper-empty manip1)

    ;; --- package starting state ---
    (package-at   package-1 shelf-A)

    ;; --- warehouse map ---
    (connected    shelf-A   corridor)
    (connected    corridor  shelf-A)
    (connected    corridor  shelf-B)
    (connected    shelf-B   corridor)
  )

  ;; GOAL: package-1 arrives at shelf-B
  (:goal
    (and
      (package-at package-1 shelf-B)
    )
  )
)