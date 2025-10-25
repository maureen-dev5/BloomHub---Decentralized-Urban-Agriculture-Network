;; BloomHub - Decentralized Urban Agriculture Network
;; A blockchain platform for cultivating communities, tracking yields,
;; and rewarding sustainable growing practices

;; Contract constants
(define-constant platform-admin tx-sender)
(define-constant err-admin-privileges (err u100))
(define-constant err-resource-missing (err u101))
(define-constant err-duplicate-record (err u102))
(define-constant err-permission-denied (err u103))
(define-constant err-validation-failed (err u104))

;; Token configuration
(define-constant token-identifier "BloomHub Growth Token")
(define-constant token-code "BGT")
(define-constant token-precision u6)
(define-constant token-supply-limit u41000000000) ;; 41k tokens with 6 decimals

;; Incentive distribution (micro-tokens)
(define-constant incentive-yield u1900000) ;; 1.9 BGT
(define-constant incentive-plot u2400000) ;; 2.4 BGT
(define-constant incentive-badge u8800000) ;; 8.8 BGT

;; State variables
(define-data-var circulating-supply uint u0)
(define-data-var plot-sequence uint u1)
(define-data-var yield-sequence uint u1)

;; Token ledger
(define-map balance-ledger principal uint)

;; Grower registry
(define-map grower-registry
  principal
  {
    display-name: (string-ascii 24),
    specialty: (string-ascii 12), ;; "vegetables", "flowers", "herbs", "fruits", "mixed"
    yield-entries: uint,
    plot-contributions: uint,
    cultivars-tracked: uint,
    grower-tier: uint, ;; 1-5
    enrollment-block: uint
  }
)

;; Plot database
(define-map plot-database
  uint
  {
    plot-title: (string-ascii 36),
    geo-location: (string-ascii 26),
    plot-classification: (string-ascii 12), ;; "community", "rooftop", "urban", "suburban"
    area-sqm: uint,
    substrate: (string-ascii 10), ;; "clay", "sandy", "loamy", "mixed"
    light-exposure: (string-ascii 8), ;; "full", "partial", "shade"
    coordinator: principal,
    yield-records: uint,
    community-rating: uint
  }
)

;; Yield registry
(define-map yield-registry
  uint
  {
    plot-reference: uint,
    grower: principal,
    cultivar: (string-ascii 20),
    mass-grams: uint,
    cultivation-style: (string-ascii 12), ;; "organic", "traditional", "hydroponic"
    growing-season: (string-ascii 8), ;; "spring", "summer", "fall", "winter"
    yield-commentary: (string-ascii 110),
    recorded-block: uint,
    harvest-success: bool
  }
)

;; Plot assessments
(define-map plot-assessments
  { plot-reference: uint, assessor: principal }
  {
    score: uint, ;; 1-10
    assessment-notes: (string-ascii 130),
    output-level: (string-ascii 8), ;; "high", "medium", "low"
    assessment-block: uint,
    endorsements: uint
  }
)

;; Grower achievements
(define-map grower-achievements
  { grower: principal, badge: (string-ascii 12) }
  {
    earned-block: uint,
    yield-total: uint
  }
)

;; Helper to retrieve or initialize grower
(define-private (fetch-or-init-grower (grower principal))
  (match (map-get? grower-registry grower)
    existing existing
    {
      display-name: "",
      specialty: "vegetables",
      yield-entries: u0,
      plot-contributions: u0,
      cultivars-tracked: u0,
      grower-tier: u1,
      enrollment-block: stacks-block-height
    }
  )
)

;; Token interface
(define-read-only (get-name)
  (ok token-identifier)
)

(define-read-only (get-symbol)
  (ok token-code)
)

(define-read-only (get-decimals)
  (ok token-precision)
)

(define-read-only (get-balance (account principal))
  (ok (default-to u0 (map-get? balance-ledger account)))
)

(define-private (distribute-tokens (receiver principal) (allocation uint))
  (let (
    (current-holdings (default-to u0 (map-get? balance-ledger receiver)))
    (updated-holdings (+ current-holdings allocation))
    (updated-supply (+ (var-get circulating-supply) allocation))
  )
    (asserts! (<= updated-supply token-supply-limit) err-validation-failed)
    (map-set balance-ledger receiver updated-holdings)
    (var-set circulating-supply updated-supply)
    (ok allocation)
  )
)

;; Register cultivation plot
(define-public (register-plot (plot-title (string-ascii 36)) (geo-location (string-ascii 26)) (plot-classification (string-ascii 12)) (area-sqm uint) (substrate (string-ascii 10)) (light-exposure (string-ascii 8)))
  (let (
    (plot-id (var-get plot-sequence))
    (grower-data (fetch-or-init-grower tx-sender))
  )
    (asserts! (> (len plot-title) u0) err-validation-failed)
    (asserts! (> (len geo-location) u0) err-validation-failed)
    (asserts! (> area-sqm u0) err-validation-failed)
    
    (map-set plot-database plot-id {
      plot-title: plot-title,
      geo-location: geo-location,
      plot-classification: plot-classification,
      area-sqm: area-sqm,
      substrate: substrate,
      light-exposure: light-exposure,
      coordinator: tx-sender,
      yield-records: u0,
      community-rating: u0
    })
    
    ;; Update grower statistics
    (map-set grower-registry tx-sender
      (merge grower-data {plot-contributions: (+ (get plot-contributions grower-data) u1)})
    )
    
    ;; Distribute plot registration incentive
    (try! (distribute-tokens tx-sender incentive-plot))
    
    (var-set plot-sequence (+ plot-id u1))
    (print {event: "plot-registered", plot-id: plot-id, coordinator: tx-sender})
    (ok plot-id)
  )
)

;; Record yield
(define-public (record-yield (plot-reference uint) (cultivar (string-ascii 20)) (mass-grams uint) (cultivation-style (string-ascii 12)) (growing-season (string-ascii 8)) (yield-commentary (string-ascii 110)) (harvest-success bool))
  (let (
    (yield-id (var-get yield-sequence))
    (plot-info (unwrap! (map-get? plot-database plot-reference) err-resource-missing))
    (grower-data (fetch-or-init-grower tx-sender))
  )
    (asserts! (> (len cultivar) u0) err-validation-failed)
    (asserts! (> mass-grams u0) err-validation-failed)
    
    (map-set yield-registry yield-id {
      plot-reference: plot-reference,
      grower: tx-sender,
      cultivar: cultivar,
      mass-grams: mass-grams,
      cultivation-style: cultivation-style,
      growing-season: growing-season,
      yield-commentary: yield-commentary,
      recorded-block: stacks-block-height,
      harvest-success: harvest-success
    })
    
    ;; Update plot yield count
    (map-set plot-database plot-reference
      (merge plot-info {yield-records: (+ (get yield-records plot-info) u1)})
    )
    
    ;; Update grower profile and distribute incentives
    (if harvest-success
      (begin
        (map-set grower-registry tx-sender
          (merge grower-data {
            yield-entries: (+ (get yield-entries grower-data) u1),
            cultivars-tracked: (+ (get cultivars-tracked grower-data) u1),
            grower-tier: (+ (get grower-tier grower-data) (/ mass-grams u1000))
          })
        )
        (try! (distribute-tokens tx-sender incentive-yield))
        true
      )
      (begin
        (map-set grower-registry tx-sender
          (merge grower-data {yield-entries: (+ (get yield-entries grower-data) u1)})
        )
        (try! (distribute-tokens tx-sender (/ incentive-yield u3)))
        true
      )
    )
    
    (var-set yield-sequence (+ yield-id u1))
    (print {event: "yield-recorded", yield-id: yield-id, plot-reference: plot-reference})
    (ok yield-id)
  )
)

;; Submit plot assessment
(define-public (submit-assessment (plot-reference uint) (score uint) (assessment-notes (string-ascii 130)) (output-level (string-ascii 8)))
  (let (
    (plot-info (unwrap! (map-get? plot-database plot-reference) err-resource-missing))
    (grower-data (fetch-or-init-grower tx-sender))
  )
    (asserts! (and (>= score u1) (<= score u10)) err-validation-failed)
    (asserts! (> (len assessment-notes) u0) err-validation-failed)
    (asserts! (is-none (map-get? plot-assessments {plot-reference: plot-reference, assessor: tx-sender})) err-duplicate-record)
    
    (map-set plot-assessments {plot-reference: plot-reference, assessor: tx-sender} {
      score: score,
      assessment-notes: assessment-notes,
      output-level: output-level,
      assessment-block: stacks-block-height,
      endorsements: u0
    })
    
    ;; Update plot community rating
    (let (
      (existing-rating (get community-rating plot-info))
      (yield-count (get yield-records plot-info))
      (updated-rating (if (> yield-count u0)
                 (/ (+ (* existing-rating yield-count) score) (+ yield-count u1))
                 score))
    )
      (map-set plot-database plot-reference (merge plot-info {community-rating: updated-rating}))
    )
    
    (print {event: "assessment-submitted", plot-reference: plot-reference, assessor: tx-sender})
    (ok true)
  )
)

;; Endorse assessment
(define-public (endorse-assessment (plot-reference uint) (assessor principal))
  (let (
    (assessment (unwrap! (map-get? plot-assessments {plot-reference: plot-reference, assessor: assessor}) err-resource-missing))
  )
    (asserts! (not (is-eq tx-sender assessor)) err-permission-denied)
    
    (map-set plot-assessments {plot-reference: plot-reference, assessor: assessor}
      (merge assessment {endorsements: (+ (get endorsements assessment) u1)})
    )
    
    (print {event: "assessment-endorsed", plot-reference: plot-reference, assessor: assessor})
    (ok true)
  )
)

;; Update specialty
(define-public (update-specialty (new-specialty (string-ascii 12)))
  (let (
    (grower-data (fetch-or-init-grower tx-sender))
  )
    (asserts! (> (len new-specialty) u0) err-validation-failed)
    
    (map-set grower-registry tx-sender (merge grower-data {specialty: new-specialty}))
    
    (print {event: "specialty-updated", grower: tx-sender, specialty: new-specialty})
    (ok true)
  )
)

;; Claim achievement badge
(define-public (claim-badge (badge (string-ascii 12)))
  (let (
    (grower-data (fetch-or-init-grower tx-sender))
  )
    (asserts! (is-none (map-get? grower-achievements {grower: tx-sender, badge: badge})) err-duplicate-record)
    
    ;; Validate badge criteria
    (let (
      (criteria-satisfied
        (if (is-eq badge "grower-50") (>= (get yield-entries grower-data) u50)
        (if (is-eq badge "community-9") (>= (get plot-contributions grower-data) u9)
        false)))
    )
      (asserts! criteria-satisfied err-permission-denied)
      
      ;; Register achievement
      (map-set grower-achievements {grower: tx-sender, badge: badge} {
        earned-block: stacks-block-height,
        yield-total: (get yield-entries grower-data)
      })
      
      ;; Distribute badge incentive
      (try! (distribute-tokens tx-sender incentive-badge))
      
      (print {event: "badge-claimed", grower: tx-sender, badge: badge})
      (ok true)
    )
  )
)

;; Update display name
(define-public (update-display-name (new-name (string-ascii 24)))
  (let (
    (grower-data (fetch-or-init-grower tx-sender))
  )
    (asserts! (> (len new-name) u0) err-validation-failed)
    (map-set grower-registry tx-sender (merge grower-data {display-name: new-name}))
    (print {event: "display-name-updated", grower: tx-sender})
    (ok true)
  )
)

;; Query functions
(define-read-only (fetch-grower-profile (grower principal))
  (map-get? grower-registry grower)
)

(define-read-only (fetch-plot-info (plot-reference uint))
  (map-get? plot-database plot-reference)
)

(define-read-only (fetch-yield-record (yield-id uint))
  (map-get? yield-registry yield-id)
)

(define-read-only (fetch-plot-assessment (plot-reference uint) (assessor principal))
  (map-get? plot-assessments {plot-reference: plot-reference, assessor: assessor})
)

(define-read-only (fetch-achievement (grower principal) (badge (string-ascii 12)))
  (map-get? grower-achievements {grower: grower, badge: badge})
)