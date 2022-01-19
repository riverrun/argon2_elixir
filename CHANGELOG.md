# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v2.4.1 (2021-01-19)

* Changes
  * updated documentation and README

## v2.4.0 (2021-01-09)

* Enhancements
  * updated Makefile to be more robust, especially for Nerves users

## v2.3.0 (2020-03-01)

* Changes
  * using Comeonin v5.3, which changes `add_hash` so that it does NOT set the password to nil

## v2.2.0 (2020-01-15)

* Enhancements
  * Updated documentation - in line with updates to Comeonin v5.2

## v2.0.0 (2019-02-12)

* Enhancements
  * Updated to use the Comeonin and Comeonin.PasswordHash behaviours (Comeonin v5.0)
  * Made Argon2id the default Argon2 type
  * Changed default t_cost, m_cost and parallelism values

## v1.3.1 (2018-06-28)

* Bug fixes
  * Added :erlang.nif_error for use with NIFs

## v1.3 (2018-05-13)

* Bug fixes
  * Fixed bug that was raising errors when used in releases

## v1.2.4 (2018-12-09)

* Enhancements
  * Improved Windows support by removing VLAs from nif code

## v1.2.0 (2017-07-14)

* Changes
  * Removed the `opts` argument to `verify_pass` - it is now `verify_pass/2`
  * Deprecated `verify_hash` - this will be removed in version 2

## v1.1.0 (2017-07-12)

* Changes
  * Added a `verify_pass` function - this is to be more in line with other libraries' verify functions

## v1.0.0 (2017-07-06)

* Changes
  * Updates to the documentation

## v0.12.0 (2017-01-16)

* Enhancements
  * Added `no_user_verify` dummy verify function to help prevent username enumeration

## v0.11.0 (2016-11-09)

* Enhancements
  * Made t_cost, m_cost and parallelism configurable with the config file
    * This makes it easier to set different values for tests

## v0.10.0 (2016-11-06)

* Enhancements
  * Added report function
    * This provides an output similar to the reference command line app
* Changes
  * Changed raw_output and encoded_output options - now there is a single format option

## v0.9.0 (2016-10-28)

* Bug fixes
  * Fixed hex package
