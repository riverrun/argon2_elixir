/* Argon2 password hashing algorithm for use with Elixir
 *
 * Copyright 2016-2017 David Whitlock
 *
 * This is licensed under the Apache Public License 2.0
 *
 * The license and copyright information for the reference implementation
 * is detailed below:
 *
 * Argon2 reference source code package - reference C implementations
 *
 * Copyright 2015
 * Daniel Dinu, Dmitry Khovratovich, Jean-Philippe Aumasson, and Samuel Neves
 *
 * You may use this work under the terms of a Creative Commons CC0 1.0
 * License/Waiver or the Apache Public License 2.0, at your option. The terms of
 * these licenses can be found at:
 *
 * - CC0 1.0 Universal : http://creativecommons.org/publicdomain/zero/1.0
 * - Apache 2.0        : http://www.apache.org/licenses/LICENSE-2.0
 *
 * You should have received a copy of both of these licenses along with this
 * software. If not, they may be obtained at the above URLs.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "argon2.h"
#include "encoding.h"
#include "core.h"
#include "erl_nif.h"

#define MAX_ENCODEDLEN 1024

ERL_NIF_TERM argon2_hash_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary pwd, salt;
	ERL_NIF_TERM result_term;
	unsigned int t_cost, m, m_cost, parallelism, raw_output, hashlen, encodedlen, type_int, version;
	argon2_type type;
	argon2_context context;
	int result;
	uint8_t *out;
	char *hash, *encoded;

	if (argc != 10 || !enif_get_uint(env, argv[0], &t_cost) ||
			!enif_get_uint(env, argv[1], &m) ||
			!enif_get_uint(env, argv[2], &parallelism) ||
			!enif_inspect_binary(env, argv[3], &pwd) ||
			!enif_inspect_binary(env, argv[4], &salt) ||
			!enif_get_uint(env, argv[5], &raw_output) ||
			!enif_get_uint(env, argv[6], &hashlen) ||
			!enif_get_uint(env, argv[7], &encodedlen) ||
			!enif_get_uint(env, argv[8], &type_int) ||
			!enif_get_uint(env, argv[9], &version))
		return enif_make_badarg(env);

	m_cost = 1U << m;
	type = (argon2_type)type_int;

	if (hashlen > ARGON2_MAX_OUTLEN) {
		return enif_make_int(env, ARGON2_OUTPUT_TOO_LONG);
	}

	if (hashlen < ARGON2_MIN_OUTLEN) {
		return enif_make_int(env, ARGON2_OUTPUT_TOO_SHORT);
	}

	out = malloc(hashlen);
	if (!out) {
		return enif_make_int(env, ARGON2_MEMORY_ALLOCATION_ERROR);
	}

	hash = malloc(hashlen * 2 + 1);
	if (!hash) {
		return enif_make_int(env, ARGON2_MEMORY_ALLOCATION_ERROR);
	}

	encoded = malloc(encodedlen + 1);
	if (!encoded) {
		return enif_make_int(env, ARGON2_MEMORY_ALLOCATION_ERROR);
	}

	context.out = out;
	context.outlen = (uint32_t)hashlen;
	context.pwd = CONST_CAST(uint8_t *)pwd.data;
	context.pwdlen = (uint32_t)pwd.size;
	context.salt = CONST_CAST(uint8_t *)salt.data;
	context.saltlen = (uint32_t)salt.size;
	context.secret = NULL;
	context.secretlen = 0;
	context.ad = NULL;
	context.adlen = 0;
	context.t_cost = t_cost;
	context.m_cost = m_cost;
	context.lanes = parallelism;
	context.threads = parallelism;
	context.allocate_cbk = NULL;
	context.free_cbk = NULL;
	context.flags = ARGON2_DEFAULT_FLAGS;
	context.version = version ? version : ARGON2_VERSION_NUMBER;

	result = argon2_ctx(&context, type);

	if (result != ARGON2_OK) {
		clear_internal_memory(out, hashlen);
		free(out);
		free(hash);
		free(encoded);
		return enif_make_int(env, result);
	}

	/* if raw hash requested, write it */
	if (raw_output) {
		int i;

		for (i = 0; i < hashlen; i++)
			sprintf(hash + i * 2, "%02x", out[i]);
	}

	/* if encoding requested, write it */
	if (encodedlen) {
		if (encode_string(encoded, encodedlen, &context, type) != ARGON2_OK) {
			clear_internal_memory(out, hashlen); /* wipe buffers if error */
			clear_internal_memory(encoded, encodedlen);
			free(out);
			free(hash);
			free(encoded);
			return enif_make_int(env, ARGON2_ENCODING_FAIL);
		}
	}

	clear_internal_memory(out, hashlen);
	free(out);

	result_term = enif_make_tuple2(env, enif_make_string(env, hash, ERL_NIF_LATIN1),
			enif_make_string(env, encoded, ERL_NIF_LATIN1));

	free(hash);
	free(encoded);
	return result_term;
}

static ERL_NIF_TERM argon2_verify_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
	char encoded[MAX_ENCODEDLEN];
	ErlNifBinary pwd;
	unsigned int type_int;
	argon2_type type;
	int ret;

	if (argc != 3 || !enif_get_string(env, argv[0], encoded, sizeof(encoded), ERL_NIF_LATIN1) ||
			!enif_inspect_binary(env, argv[1], &pwd) ||
			!enif_get_uint(env, argv[2], &type_int))
		return enif_make_badarg(env);

	type = (argon2_type)type_int;

	ret = argon2_verify(encoded, pwd.data, pwd.size, type);
	return enif_make_int(env, ret);
}

static ERL_NIF_TERM argon2_error_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
	int error_code;
	char const *ret;

	if (argc != 1 || !enif_get_int(env, argv[0], &error_code))
		return enif_make_badarg(env);

	ret = argon2_error_message(error_code);
	return enif_make_string(env, ret, ERL_NIF_LATIN1);
}

static ERL_NIF_TERM argon2_encodedlen_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
	unsigned int t_cost, m, m_cost, parallelism, saltlen, hashlen, type_int;
	argon2_type type;
	int ret;

	if (argc != 6 || !enif_get_uint(env, argv[0], &t_cost) ||
			!enif_get_uint(env, argv[1], &m) ||
			!enif_get_uint(env, argv[2], &parallelism) ||
			!enif_get_uint(env, argv[3], &saltlen) ||
			!enif_get_uint(env, argv[4], &hashlen) ||
			!enif_get_uint(env, argv[5], &type_int))
		return enif_make_badarg(env);

	m_cost = 1U << m;
	type = (argon2_type)type_int;

	ret = argon2_encodedlen(t_cost, m_cost, parallelism, saltlen, hashlen, type);
	return enif_make_int(env, ret);
}

static int upgrade(ErlNifEnv *env, void **priv_data, void **old_priv_data, ERL_NIF_TERM load_info)
{
	return 0;
}

static ErlNifFunc argon2_nif_funcs[] =
{
	{"hash_nif", 10, argon2_hash_nif, ERL_NIF_DIRTY_JOB_CPU_BOUND},
	{"verify_nif", 3, argon2_verify_nif, ERL_NIF_DIRTY_JOB_CPU_BOUND},
	{"error_nif", 1, argon2_error_nif},
	{"encodedlen_nif", 6, argon2_encodedlen_nif}
};

ERL_NIF_INIT(Elixir.Argon2.Base, argon2_nif_funcs, NULL, NULL, upgrade, NULL)
