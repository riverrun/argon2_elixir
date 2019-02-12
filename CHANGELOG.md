# Changelog

## v2.0.0

* Enhancements
  * Updated to use the Comeonin and Comeonin.PasswordHash behaviours (Comeonin v5.0)
  * Made Argon2id the default Argon2 type
  * Changed default t_cost, m_cost and parallelism values

## v1.3.1

* Bug fixes
  * Added :erlang.nif_error for use with NIFs

## v1.3

* Bug fixes
  * Fixed bug that was raising errors when used in releases

## v1.2.4

* Enhancements
  * Improved Windows support by removing VLAs from nif code

## v1.2.0

* Changes
  * Removed the `opts` argument to `verify_pass` - it is now `verify_pass/2`
  * Deprecated `verify_hash` - this will be removed in version 2

## v1.1.0

* Changes
  * Added a `verify_pass` function - this is to be more in line with other libraries' verify functions

## v1.0.0

* Changes
  * Updates to the documentation

## v0.12.0

* Enhancements
  * Added `no_user_verify` dummy verify function to help prevent username enumeration

## v0.11.0

* Enhancements
  * Made t_cost, m_cost and parallelism configurable with the config file
    * This makes it easier to set different values for tests

## v0.10.0

* Enhancements
  * Added report function
    * This provides an output similar to the reference command line app
* Changes
  * Changed raw_output and encoded_output options - now there is a single format option

## v0.9.0

* Bug fixes
  * Fixed hex package
