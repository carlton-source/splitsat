;; title: vault
;; version: 0.1.0
;; summary: SplitSat Vault
;; description: Splits STX stacking deposits into a Principal Token (PT) and
;;   a Yield Token (YT). PT redeems 1:1 for the deposited STX after maturity.
;;   YT redeems for a pro-rata share of the sBTC PoX rewards accrued in the
;;   vault before maturity.

;; constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant SBTC_TOKEN 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-constant ERR_OWNER_ONLY (err u200))
(define-constant ERR_MATURITY_ALREADY_SET (err u201))
(define-constant ERR_INVALID_MATURITY (err u202))
(define-constant ERR_BEFORE_MATURITY (err u203))
(define-constant ERR_AFTER_MATURITY (err u204))
(define-constant ERR_ZERO_AMOUNT (err u205))
(define-constant ERR_NO_YIELD_SUPPLY (err u206))
(define-constant ERR_PAUSED (err u207))
(define-constant ERR_DEPOSIT_CAP_EXCEEDED (err u208))

;; data vars

;; Stacks block height after which deposits close and redemptions open.
(define-data-var maturity-height uint u0)
(define-data-var maturity-set bool false)

;; Total sBTC PoX rewards accrued in the vault, claimable pro-rata by YT holders.
(define-data-var btc-yield-pool uint u0)

;; Emergency pause: blocks new deposits and yield top-ups. Redemptions
;; (redeem-principal / redeem-yield) remain available even while paused.
(define-data-var paused bool false)

;; Total STX currently locked via deposit (reduced as principal is redeemed).
;; Bounded by deposit-cap to limit at-risk funds during the unaudited
;; mainnet launch.
(define-data-var total-deposited uint u0)
(define-data-var deposit-cap uint u1000000000) ;; default: 1,000 STX (in microstacks)

;; public functions

;; One-time setup: lock in the maturity height for this vault epoch.
(define-public (set-maturity-height (height uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (asserts! (not (var-get maturity-set)) ERR_MATURITY_ALREADY_SET)
    (asserts! (> height stacks-block-height) ERR_INVALID_MATURITY)
    (var-set maturity-height height)
    (var-set maturity-set true)
    (ok true)
  )
)

;; Emergency pause switch. While paused, deposit and add-yield are blocked;
;; redeem-principal and redeem-yield remain available so users can always
;; exit.
(define-public (set-paused (new-paused bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (var-set paused new-paused)
    (ok new-paused)
  )
)

;; Adjust the maximum total STX that can be locked via deposit. Lets the
;; owner raise the cap gradually as the unaudited contract proves itself.
(define-public (set-deposit-cap (new-cap uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (asserts! (> new-cap u0) ERR_ZERO_AMOUNT)
    (var-set deposit-cap new-cap)
    (ok new-cap)
  )
)

;; Deposit STX before maturity, receive equal amounts of PT and YT.
(define-public (deposit (amount uint))
  (begin
    (asserts! (> amount u0) ERR_ZERO_AMOUNT)
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (not (is-matured)) ERR_AFTER_MATURITY)
    (asserts! (<= (+ (var-get total-deposited) amount) (var-get deposit-cap))
      ERR_DEPOSIT_CAP_EXCEEDED
    )
    (try! (stx-transfer? amount tx-sender current-contract))
    (try! (contract-call? .principal-token vault-mint amount tx-sender))
    (try! (contract-call? .yield-token vault-mint amount tx-sender))
    (var-set total-deposited (+ (var-get total-deposited) amount))
    (ok amount)
  )
)
