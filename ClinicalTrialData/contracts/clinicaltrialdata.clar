;; ClinicalTrialData - Secure sharing of clinical trial data
;; Version: 1.0.0

;; Data structures
(define-map trials
  { trial-id: (string-ascii 64) }
  { 
    name: (string-ascii 64),
    description: (string-ascii 256),
    start-date: uint,
    end-date: uint,
    principal-investigator: principal,
    status: (string-ascii 16)
  })

(define-map trial-data-points
  { trial-id: (string-ascii 64), data-point-id: (string-ascii 64) }
  { 
    timestamp: uint,
    data-hash: (string-ascii 128),
    metadata: (string-ascii 256),
    submitter: principal
  })

(define-map authorized-researchers
  { trial-id: (string-ascii 64), researcher: principal }
  { 
    access-level: (string-ascii 16),
    granted-at: uint,
    granted-by: principal
  })

(define-data-var admin principal tx-sender)

;; Register a new clinical trial
(define-public (register-trial
  (trial-id (string-ascii 64))
  (name (string-ascii 64))
  (description (string-ascii 256))
  (start-date uint)
  (end-date uint))
  (begin
    (asserts! (not (is-some (map-get? trials { trial-id: trial-id }))) (err u409))
    (ok (map-set trials
      { trial-id: trial-id }
      { 
        name: name,
        description: description,
        start-date: start-date,
        end-date: end-date,
        principal-investigator: tx-sender,
        status: "registered"
      }))))

;; Update trial status
(define-public (update-trial-status
  (trial-id (string-ascii 64))
  (new-status (string-ascii 16)))
  (let ((trial (map-get? trials { trial-id: trial-id })))
    (begin
      (asserts! (is-some trial) (err u404))
      (asserts! (is-eq (get principal-investigator (unwrap-panic trial)) tx-sender) (err u403))
      (ok (map-set trials
        { trial-id: trial-id }
        (merge (unwrap-panic trial) { status: new-status }))))))

;; Add a data point to a trial
(define-public (add-data-point
  (trial-id (string-ascii 64))
  (data-point-id (string-ascii 64))
  (data-hash (string-ascii 128))
  (metadata (string-ascii 256)))
  (let ((trial (map-get? trials { trial-id: trial-id }))
        (researcher-access (map-get? authorized-researchers { trial-id: trial-id, researcher: tx-sender })))
    (begin
      (asserts! (is-some trial) (err u404))
      (asserts! (or 
                  (is-eq (get principal-investigator (unwrap-panic trial)) tx-sender)
                  (and 
                    (is-some researcher-access)
                    (or 
                      (is-eq (get access-level (unwrap-panic researcher-access)) "write")
                      (is-eq (get access-level (unwrap-panic researcher-access)) "admin"))))
                (err u403))
      (asserts! (not (is-some (map-get? trial-data-points 
                              { trial-id: trial-id, data-point-id: data-point-id }))) 
                (err u409))
      (ok (map-set trial-data-points
        { trial-id: trial-id, data-point-id: data-point-id }
        { 
          timestamp: block-height,
          data-hash: data-hash,
          metadata: metadata,
          submitter: tx-sender
        })))))

;; Grant access to a researcher
(define-public (grant-researcher-access
  (trial-id (string-ascii 64))
  (researcher principal)
  (access-level (string-ascii 16)))
  (let ((trial (map-get? trials { trial-id: trial-id })))
    (begin
      (asserts! (is-some trial) (err u404))
      (asserts! (is-eq (get principal-investigator (unwrap-panic trial)) tx-sender) (err u403))
      (ok (map-set authorized-researchers
        { trial-id: trial-id, researcher: researcher }
        { 
          access-level: access-level,
          granted-at: block-height,
          granted-by: tx-sender
        })))))

;; Revoke access from a researcher
(define-public (revoke-researcher-access
  (trial-id (string-ascii 64))
  (researcher principal))
  (let ((trial (map-get? trials { trial-id: trial-id })))
    (begin
      (asserts! (is-some trial) (err u404))
      (asserts! (is-eq (get principal-investigator (unwrap-panic trial)) tx-sender) (err u403))
      (ok (map-delete authorized-researchers { trial-id: trial-id, researcher: researcher })))))

;; Get trial details
(define-read-only (get-trial-details (trial-id (string-ascii 64)))
  (map-get? trials { trial-id: trial-id }))

;; Get data point details
(define-read-only (get-data-point
  (trial-id (string-ascii 64))
  (data-point-id (string-ascii 64)))
  (map-get? trial-data-points { trial-id: trial-id, data-point-id: data-point-id }))

;; Check if a researcher has access to a trial
(define-read-only (check-researcher-access
  (trial-id (string-ascii 64))
  (researcher principal))
  (map-get? authorized-researchers { trial-id: trial-id, researcher: researcher }))
  