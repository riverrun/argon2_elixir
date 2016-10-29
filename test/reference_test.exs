defmodule Argon2ReferenceTest do
  use ExUnit.Case

  import Argon2TestHelper

  alias Argon2.Base

  test "reference implementation tests" do
    version = 0x13
    hashtest(version, 2, 16, 1, "password", "somesalt",
             "c1628832147d9720c5bd1cfd61367078729f6dfb6f8fea9ff98158e0d7816ed0",
             "$argon2i$v=19$m=65536,t=2,p=1$c29tZXNhbHQ" <>
             "$wWKIMhR9lyDFvRz9YTZweHKfbftvj+qf+YFY4NeBbtA")
    hashtest(version, 2, 18, 1, "password", "somesalt",
             "296dbae80b807cdceaad44ae741b506f14db0959267b183b118f9b24229bc7cb",
             "$argon2i$v=19$m=262144,t=2,p=1$c29tZXNhbHQ" <>
             "$KW266AuAfNzqrUSudBtQbxTbCVkmexg7EY+bJCKbx8s")
    hashtest(version, 2, 8, 1, "password", "somesalt",
             "89e9029f4637b295beb027056a7336c414fadd43f6b208645281cb214a56452f",
             "$argon2i$v=19$m=256,t=2,p=1$c29tZXNhbHQ" <>
             "$iekCn0Y3spW+sCcFanM2xBT63UP2sghkUoHLIUpWRS8")
    hashtest(version, 2, 8, 2, "password", "somesalt",
             "4ff5ce2769a1d7f4c8a491df09d41a9fbe90e5eb02155a13e4c01e20cd4eab61",
             "$argon2i$v=19$m=256,t=2,p=2$c29tZXNhbHQ" <>
             "$T/XOJ2mh1/TIpJHfCdQan76Q5esCFVoT5MAeIM1Oq2E")
    hashtest(version, 1, 16, 1, "password", "somesalt",
             "d168075c4d985e13ebeae560cf8b94c3b5d8a16c51916b6f4ac2da3ac11bbecf",
             "$argon2i$v=19$m=65536,t=1,p=1$c29tZXNhbHQ" <>
             "$0WgHXE2YXhPr6uVgz4uUw7XYoWxRkWtvSsLaOsEbvs8")
    hashtest(version, 4, 16, 1, "password", "somesalt",
             "aaa953d58af3706ce3df1aefd4a64a84e31d7f54175231f1285259f88174ce5b",
             "$argon2i$v=19$m=65536,t=4,p=1$c29tZXNhbHQ" <>
             "$qqlT1YrzcGzj3xrv1KZKhOMdf1QXUjHxKFJZ+IF0zls")
    hashtest(version, 2, 16, 1, "differentpassword", "somesalt",
             "14ae8da01afea8700c2358dcef7c5358d9021282bd88663a4562f59fb74d22ee",
             "$argon2i$v=19$m=65536,t=2,p=1$c29tZXNhbHQ" <>
             "$FK6NoBr+qHAMI1jc73xTWNkCEoK9iGY6RWL1n7dNIu4")
    hashtest(version, 2, 16, 1, "password", "diffsalt",
             "b0357cccfbef91f3860b0dba447b2348cbefecadaf990abfe9cc40726c521271",
             "$argon2i$v=19$m=65536,t=2,p=1$ZGlmZnNhbHQ" <>
             "$sDV8zPvvkfOGCw26RHsjSMvv7K2vmQq/6cxAcmxSEnE")
  end

  test "invalid encoding error handling" do
    ret = verify_test_helper("$argon2i$v=19$m=65536,t=2,p=1c29tZXNhbHQ" <>
                             "$wWKIMhR9lyDFvRz9YTZweHKfbftvj+qf+YFY4NeBbtA",
                             "password", 1);
    assert ret == -32
    ret = verify_test_helper("$argon2i$v=19$m=65536,t=2,p=1$c29tZXNhbHQ" <>
                             "wWKIMhR9lyDFvRz9YTZweHKfbftvj+qf+YFY4NeBbtA",
                             "password", 1);
    assert ret == -32
  end

  test "common error states" do
    ret = Base.hash_nif(1, 1, 1, "password", "diffsalt", 1, 32, 108, 1, 0x10)
    assert ret == -14
  end

  test "version ARGON2_VERSION_10" do
    version = 0x10
    hashtest(version, 2, 16, 1, "password", "somesalt",
             "f6c4db4a54e2a370627aff3db6176b94a2a209a62c8e36152711802f7b30c694",
             "$argon2i$m=65536,t=2,p=1$c29tZXNhbHQ" <>
             "$9sTbSlTio3Biev89thdrlKKiCaYsjjYVJxGAL3swxpQ")
    hashtest(version, 2, 18, 1, "password", "somesalt",
             "3e689aaa3d28a77cf2bc72a51ac53166761751182f1ee292e3f677a7da4c2467",
             "$argon2i$m=262144,t=2,p=1$c29tZXNhbHQ" <>
             "$Pmiaqj0op3zyvHKlGsUxZnYXURgvHuKS4/Z3p9pMJGc")
    hashtest(version, 2, 8, 1, "password", "somesalt",
             "fd4dd83d762c49bdeaf57c47bdcd0c2f1babf863fdeb490df63ede9975fccf06",
             "$argon2i$m=256,t=2,p=1$c29tZXNhbHQ" <>
             "$/U3YPXYsSb3q9XxHvc0MLxur+GP960kN9j7emXX8zwY")
  end

end
