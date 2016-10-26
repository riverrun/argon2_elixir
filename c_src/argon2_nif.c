/* Argon2 password hashing algorithm for use with Elixir
 *
 * Copyright 2016 David Whitlock
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

#include "argon2.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "erl_nif.h"

static ERL_NIF_TERM argon2_hash_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary pwd, salt;
	unsigned int t_cost, m, m_cost, parallelism, raw_output, hashlen, encodedlen;
	argon2_type type;
	int ret;

	if (argc != 9 || !enif_get_uint(env, argv[0], &t_cost) ||
			!enif_get_uint(env, argv[1], &m) ||
			!enif_get_uint(env, argv[2], &parallelism) ||
			!enif_inspect_binary(env, argv[3], &pwd) ||
			!enif_inspect_binary(env, argv[4], &salt) ||
			!enif_get_uint(env, argv[5], &raw_output) ||
			!enif_get_uint(env, argv[6], &hashlen) ||
			!enif_get_uint(env, argv[7], &encodedlen) ||
			!enif_get_uint(env, argv[8], &type))
		return enif_make_badarg(env);

	m_cost = (1<<m);

	uint8_t hash[hashlen];
	char output[hashlen * 2 + 1];
	char encoded[encodedlen];

	ret = argon2_hash(t_cost, m_cost, parallelism, pwd.data, pwd.size, salt.data, salt.size,
			hash, hashlen, encoded, encodedlen, type, ARGON2_VERSION_NUMBER);
	if (ret)
		return enif_make_int(env, ret);

	if (raw_output) {
		size_t i;

		for (i = 0; i < hashlen; i++)
			sprintf(output + i * 2, "%02x", hash[i]);
	}

	return enif_make_tuple2(env, enif_make_string(env, output, ERL_NIF_LATIN1),
			enif_make_string(env, encoded, ERL_NIF_LATIN1));
}

static ERL_NIF_TERM argon2_verify_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	char encoded[1024];
	ErlNifBinary pwd;
	argon2_type type;
	int ret;

	if (argc != 3 || !enif_get_string(env, argv[0], encoded, sizeof(encoded), ERL_NIF_LATIN1) ||
			!enif_inspect_binary(env, argv[1], &pwd) ||
			!enif_get_uint(env, argv[2], &type))
		return enif_make_badarg(env);

	ret = argon2_verify(encoded, pwd.data, pwd.size, type);
	return enif_make_int(env, ret);
}

static ERL_NIF_TERM argon2_error_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int error_code;
	char const *ret;

	if (argc != 1 || !enif_get_int(env, argv[0], &error_code))
		return enif_make_badarg(env);

	ret = argon2_error_message(error_code);
	return enif_make_string(env, ret, ERL_NIF_LATIN1);
}

static ERL_NIF_TERM argon2_encodedlen_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	unsigned int t_cost, m, m_cost, parallelism, saltlen, hashlen;
	argon2_type type;
	int ret;

	if (argc != 6 || !enif_get_uint(env, argv[0], &t_cost) ||
			!enif_get_uint(env, argv[1], &m) ||
			!enif_get_uint(env, argv[2], &parallelism) ||
			!enif_get_uint(env, argv[3], &saltlen) ||
			!enif_get_uint(env, argv[4], &hashlen) ||
			!enif_get_uint(env, argv[5], &type))
		return enif_make_badarg(env);

	m_cost = (1<<m);

	ret = argon2_encodedlen(t_cost, m_cost, parallelism, saltlen, hashlen, type);
	return enif_make_int(env, ret);
}

static int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
	return 0;
}

static ErlNifFunc argon2_nif_funcs[] =
{
	{"hash_nif", 9, argon2_hash_nif},
	{"verify_nif", 3, argon2_verify_nif},
	{"error_nif", 1, argon2_error_nif},
	{"encodedlen_nif", 6, argon2_encodedlen_nif}
};

ERL_NIF_INIT(Elixir.Argon2.Base, argon2_nif_funcs, NULL, NULL, upgrade, NULL)
