#include "argon2.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "erl_nif.h"

static ERL_NIF_TERM argon2_hash_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary pwd, salt;
	unsigned int t_cost, m, m_cost, parallelism, hashlen, isencoded;
	argon2_type type;

	if (argc != 8 || !enif_get_uint(env, argv[0], &t_cost) ||
			!enif_get_uint(env, argv[1], &m) ||
			!enif_get_uint(env, argv[2], &parallelism) ||
			!enif_inspect_binary(env, argv[3], &pwd) ||
			!enif_inspect_binary(env, argv[4], &salt) ||
			!enif_get_uint(env, argv[5], &hashlen) ||
			!enif_get_uint(env, argv[6], &isencoded) ||
			!enif_get_uint(env, argv[7], &type))
		return enif_make_badarg(env);

	m_cost = (1<<m);

	if (isencoded) {
		size_t encodedlen = argon2_encodedlen(t_cost, m_cost, parallelism,
				salt.size, hashlen, type);
		char encoded[encodedlen];

		argon2_hash(t_cost, m_cost, parallelism, pwd.data, pwd.size, salt.data, salt.size,
				NULL, hashlen, encoded, encodedlen, type, ARGON2_VERSION_NUMBER);
		return enif_make_string(env, encoded, ERL_NIF_LATIN1);
	}
	else {
		uint8_t hash[hashlen];
		char output[hashlen * 2 + 1];
		size_t i;

		argon2_hash(t_cost, m_cost, parallelism, pwd.data, pwd.size, salt.data, salt.size,
				hash, hashlen, NULL, 0, type, ARGON2_VERSION_NUMBER);
		for (i = 0; i < hashlen; i++) {
			sprintf(output + 2 * i, "%02x", hash[i]);
		}
		return enif_make_string(env, output, ERL_NIF_LATIN1);
	}
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

static int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
	return 0;
}

static ErlNifFunc argon2_nif_funcs[] =
{
	{"argon2_hash_nif", 8, argon2_hash_nif},
	{"argon2_verify_nif", 3, argon2_verify_nif}
};

ERL_NIF_INIT(Elixir.Argon2, argon2_nif_funcs, NULL, NULL, upgrade, NULL)
