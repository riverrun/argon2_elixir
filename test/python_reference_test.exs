defmodule Argon2.PythonReferenceTest do
  use ExUnit.Case

  @pass_hashes [
    {"password", "$argon2i$v=19$m=65536,t=6,p=1$ZSFmimH0uZkOIPTgZX2QWA$c98Jib7O89BBOnO4YNAkdA"},
    {"aáåäeéêëoôö",
     "$argon2i$v=19$m=65536,t=6,p=1$C9R4/3fqN2FNW01MHRXtaw$cLD87IO9DNW1EI/sJka4TA"},
    {
      "Сколько лет, сколько зим",
      "$argon2i$v=19$m=65536,t=6,p=1$mE78Um6wBWYojv/yEsGIoA$itfghPO2IC5A4THXfI5Ciw"
    },
    {"สวัสดีครับ", "$argon2i$v=19$m=65536,t=6,p=1$ZoxhWxwAz+xG7abtOtFtOQ$p2sFiyFclHC2C9de9OJrBA"},
    {"Я❤três☕ où☔",
     "$argon2i$v=19$m=65536,t=6,p=1$KdBA655nrjQCsee0+8zj8w$SrV0KG+G0M4JIhaY3pRitw"},
    {
      "C'est bon, la vie!",
      "$argon2i$v=19$m=65536,t=6,p=1$0FN5kRHxa4GSmJNJX3KREw$DvY1LkV+VxSZMByQZqHuVA"
    },
    {
      "ἓν οἶδα ὅτι οὐδὲν οἶδα",
      "$argon2i$v=19$m=65536,t=6,p=1$m2yKG4/7Y4xyW4+Bd+aEpQ$CU3LEjCFqYdEqyTtC0nF+Q"
    }
  ]

  test "test verify_pass with hashes produced by the python cffi implementation" do
    for {password, hash} <- @pass_hashes do
      assert Argon2.verify_pass(password, hash) == true
    end
  end
end
