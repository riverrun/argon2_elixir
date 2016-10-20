#include "argon2.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "erl_nif.h"

#define HASHLEN 32

static ERL_NIF_TERM argon2_hash_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary pwd, salt;
	uint8_t hash[HASHLEN];
	ERL_NIF_TERM output[HASHLEN];
	uint32_t t_cost = 2;
	uint32_t m_cost = (1<<16);
	uint32_t parallelism = 1;
	int i;

	if (argc != 2 || !enif_inspect_binary(env, argv[0], &pwd) ||
			!enif_inspect_binary(env, argv[1], &salt))
		return enif_make_badarg(env);

	argon2_hash(t_cost, m_cost, parallelism, pwd.data, pwd.size, salt.data, salt.size,
			hash, HASHLEN, NULL, 0, Argon2_i, ARGON2_VERSION_NUMBER);

	for (i = 0; i < HASHLEN; i++) {
		output[i] = enif_make_uint(env, hash[i]);
	}

	return enif_make_list_from_array(env, output, HASHLEN);
}

static int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
	return 0;
}

static ErlNifFunc argon2_nif_funcs[] =
{
	{"argon2_hash_nif", 2, argon2_hash_nif}
};

ERL_NIF_INIT(Elixir.Argon2, argon2_nif_funcs, NULL, NULL, upgrade, NULL)
