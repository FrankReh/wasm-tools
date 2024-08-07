;; Shared struct declaration syntax
(module
  (type (shared (struct)))
  (type (sub final (shared (struct))))
  (rec
    (type (sub final (shared (struct))))
  )

  (global (ref 0) (struct.new 1))
  (global (ref 1) (struct.new 2))
  (global (ref 2) (struct.new 0))
)

;; Shared structs are distinct from non-shared structs
(assert_invalid
  (module
    (type (shared (struct)))
    (type (struct))

    (global (ref 0) (struct.new 1))
  )
  "type mismatch"
)

(assert_invalid
  (module
    (type (shared (struct)))
    (type (struct))

    (global (ref 1) (struct.new 0))
  )
  "type mismatch"
)

;; Shared structs may not be subtypes of non-shared structs
(assert_invalid
  (module
    (type (sub (struct)))
    (type (sub 0 (shared (struct))))
  )
  "must match super type"
)

;; Non-shared structs may not be subtypes of shared structs
(assert_invalid
  (module
    (type (sub (shared (struct))))
    (type (sub 0 (struct)))
  )
  "must match super type"
)

;; Shared structs may not contain non-shared references
(assert_invalid
  (module
    (type (shared (struct (field anyref))))
  )
  "must contain shared type"
)

;; But they may contain shared references
(module
  (type (shared (struct (field (ref null (shared any))))))
)

;; Non-shared structs may contain shared references
(module
  (type (struct (field (ref null (shared any)))))
)

;; Struct instructions work on shared structs.
(module
  (type $i8 (shared (struct (field (mut i8)))))
  (type $i32 (shared (struct (field (mut i32)))))
  (type $unshared (struct (field (mut i8))))

  (func (struct.new $i8 (i32.const 0)) (drop))

  (func (struct.new_default $i8) (drop))

  (func (param (ref null $i8))
    (struct.get_s $i8 0 (local.get 0)) (drop))

  (func (param (ref null $i8))
    (struct.get_u $i8 0 (local.get 0)) (drop))

  (func (param (ref null $i32))
    (struct.get $i32 0 (local.get 0)) (drop))

  (func (param (ref null $i8))
    (struct.set $i8 0 (local.get 0) (i32.const 0)))
)
