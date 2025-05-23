;; Equipment Registration Contract
;; Records industrial machinery information

(define-data-var last-equipment-id uint u0)

(define-map equipments
  { equipment-id: uint }
  {
    owner: principal,
    name: (string-utf8 100),
    model: (string-utf8 100),
    serial-number: (string-utf8 100),
    manufacture-date: uint,
    registration-date: uint
  }
)

(define-public (register-equipment
                (name (string-utf8 100))
                (model (string-utf8 100))
                (serial-number (string-utf8 100))
                (manufacture-date uint))
  (let ((new-id (+ (var-get last-equipment-id) u1)))
    (begin
      (var-set last-equipment-id new-id)
      (map-set equipments
        { equipment-id: new-id }
        {
          owner: tx-sender,
          name: name,
          model: model,
          serial-number: serial-number,
          manufacture-date: manufacture-date,
          registration-date: block-height
        }
      )
      (ok new-id)
    )
  )
)

(define-read-only (get-equipment (equipment-id uint))
  (map-get? equipments { equipment-id: equipment-id })
)

(define-read-only (get-equipment-count)
  (var-get last-equipment-id)
)

(define-public (transfer-equipment (equipment-id uint) (new-owner principal))
  (let ((equipment (unwrap! (get-equipment equipment-id) (err u1))))
    (begin
      (asserts! (is-eq tx-sender (get owner equipment)) (err u2))
      (map-set equipments
        { equipment-id: equipment-id }
        (merge equipment { owner: new-owner })
      )
      (ok true)
    )
  )
)
