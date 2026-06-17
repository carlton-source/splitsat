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
