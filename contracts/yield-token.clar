;; title: yield-token
;; version: 0.1.0
;; summary: SplitSat Yield Token (YT)
;; description: SIP-010 token redeemable for a pro-rata share of the sBTC
;;   staking-reward pool accrued in the SplitSat vault, after the vault's
;;   maturity height. Mint and burn are restricted to the companion .vault
;;   contract.

;; traits
(impl-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.sip-010-trait-ft-standard.sip-010-trait)

;; token definitions
(define-fungible-token yt-splitsat)

;; constants
(define-constant TOKEN_NAME "SplitSat Yield Token")
(define-constant TOKEN_SYMBOL "YT-SPLIT")
(define-constant TOKEN_DECIMALS u6)

(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_NOT_VAULT (err u102))

;; data vars
(define-data-var token-uri (optional (string-utf8 256)) none)

;; public functions

;; SIP-010: transfer
(define-public (transfer
    (amount uint)
    (sender principal)
    (recipient principal)
    (memo (optional (buff 34)))
  )
  (begin
    ;; #[filter(amount, recipient)]
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender))
      ERR_NOT_TOKEN_OWNER
    )
    (try! (ft-transfer? yt-splitsat amount sender recipient))
    (match memo
      to-print (print to-print)
      0x
    )
    (ok true)
  )
)

;; Mint yield tokens 1:1 with a vault deposit. Only callable by .vault.
(define-public (vault-mint
    (amount uint)
    (recipient principal)
  )
  (begin
    (asserts! (is-eq contract-caller .vault) ERR_NOT_VAULT)
    (ft-mint? yt-splitsat amount recipient)
  )
)

;; Burn yield tokens on redemption. Only callable by .vault.
(define-public (vault-burn
    (amount uint)
    (owner principal)
  )
  (begin
    (asserts! (is-eq contract-caller .vault) ERR_NOT_VAULT)
    (ft-burn? yt-splitsat amount owner)
  )
)

;; read only functions

;; SIP-010: get-balance
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance yt-splitsat who))
)

;; SIP-010: get-total-supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply yt-splitsat))
)

;; SIP-010: get-name
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;; SIP-010: get-symbol
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;; SIP-010: get-decimals
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

;; SIP-010: get-token-uri
(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)
