defmodule Argon2Test do
  use ExUnit.Case

  def permute([]), do: [[]]
  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x|y]
  end

  def hash_check_password(password, wrong1, wrong2, wrong3) do
    for argon2_type <- 0..2 do
      hash = Argon2.hash_pwd_salt(password, [argon2_type: argon2_type])
      assert Argon2.verify_hash(hash, password, [argon2_type: argon2_type]) == true
      assert Argon2.verify_hash(hash, wrong1, [argon2_type: argon2_type]) == false
      assert Argon2.verify_hash(hash, wrong2, [argon2_type: argon2_type]) == false
      assert Argon2.verify_hash(hash, wrong3, [argon2_type: argon2_type]) == false
    end
  end

  test "hashing and checking passwords" do
    hash_check_password("password", "passwor", "passwords", "pasword")
    hash_check_password("hard2guess", "ha rd2guess", "had2guess", "hardtoguess")
  end

  test "hashing and checking passwords with characters from the extended ascii set" do
    hash_check_password("aáåäeéêëoôö", "aáåäeéêëoö", "aáåeéêëoôö", "aáå äeéêëoôö")
    hash_check_password("aáåä eéêëoôö", "aáåä eéê ëoö", "a áåeé êëoôö", "aáå äeéêëoôö")
  end

  test "hashing and checking passwords with non-ascii characters" do
    hash_check_password("Сколько лет, сколько зим", "Сколько лет,сколько зим",
                        "Сколько лет сколько зим", "Сколько лет, сколько")
    hash_check_password("สวัสดีครับ", "สวัดีครับ", "สวัสสดีครับ", "วัสดีครับ")
  end

  test "hashing and checking passwords with mixed characters" do
    hash_check_password("Я❤três☕ où☔", "Я❤tres☕ où☔", "Я❤três☕où☔", "Я❤três où☔")
  end

end
