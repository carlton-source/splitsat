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