;; Manufacturer Verification Contract
;; This contract validates legitimate parts producers in the automotive supply chain

(define-data-var admin principal tx-sender)

;; Map to store verified manufacturers
(define-map verified-manufacturers principal
  {
    name: (string-utf8 100),
    verification-date: uint,
    status: bool,
    certification-id: (string-utf8 50)
  }
)

;; Public function to verify a manufacturer (admin only)
(define-public (verify-manufacturer
    (manufacturer principal)
    (name (string-utf8 100))
    (certification-id (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (not (is-some (map-get? verified-manufacturers manufacturer))) (err u100))
    (ok (map-set verified-manufacturers
      manufacturer
      {
        name: name,
        verification-date: block-height,
        status: true,
        certification-id: certification-id
      }
    ))
  )
)

;; Public function to revoke manufacturer verification (admin only)
(define-public (revoke-manufacturer (manufacturer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? verified-manufacturers manufacturer)) (err u404))
    (let ((manufacturer-data (unwrap-panic (map-get? verified-manufacturers manufacturer))))
      (ok (map-set verified-manufacturers
        manufacturer
        (merge manufacturer-data { status: false })
      ))
    )
  )
)

;; Public function to check if a manufacturer is verified
(define-read-only (is-verified-manufacturer (manufacturer principal))
  (match (map-get? verified-manufacturers manufacturer)
    manufacturer-data (ok (get status manufacturer-data))
    (err u404)
  )
)

;; Public function to get manufacturer details
(define-read-only (get-manufacturer-details (manufacturer principal))
  (map-get? verified-manufacturers manufacturer)
)

;; Public function to transfer admin rights (admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
