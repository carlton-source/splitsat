;; title: principal-token
;; version: 0.1.0
;; summary: SplitSat Principal Token (PT)
;; description: SIP-010 token redeemable 1:1 for the STX principal deposited
;;   into the SplitSat vault, after the vault's maturity height. Mint and burn
;;   are restricted to the companion .vault contract.

;; traits
(impl-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.sip-010-trait-ft-standard.sip-010-trait)

;; token definitions
(define-fungible-token pt-splitsat)

;; constants
(define-constant TOKEN_NAME "SplitSat Principal Token")
(define-constant TOKEN_SYMBOL "PT-SPLIT")
(define-constant TOKEN_DECIMALS u6)