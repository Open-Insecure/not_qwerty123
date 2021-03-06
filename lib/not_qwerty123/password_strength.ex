defmodule NotQwerty123.PasswordStrength do
  @moduledoc """
  Module to check password strength.

  This module does not provide a password strength meter. Instead, it
  simply rejects passwords that are considered too weak. Depending on
  the nature of your application, a solid front end solution to password
  checking, such as [this Dropbox implementation](https://github.com/dropbox/zxcvbn)
  might be a better idea.

  ## Password strength

  In simple terms, password strength depends on how long a password is
  and how easy it is to guess it. In most cases, passwords should be at
  least 8 characters long, and they should not be similar to common
  passwords, like `password` or `qwerty123`, or consist of repeated
  characters, like `abcabcabcabc`. Dictionary words, common names
  and user-specific words (company name, address, etc.) should also
  be avoided.

  It is important to note that these guidelines, especially those regarding
  password length, apply to online attacks, where the number of password
  attempts is limited. With offline attacks, in the case of a database leak
  for example, it will be far easier for an attacker to find the password,
  and you might want to protect against that by adopting more stringent
  password guidelines.

  ## Further information

  Visit the [Comeonin wiki](https://github.com/elixircnx/comeonin/wiki)
  for links to further information about password-related issues.

  """

  import NotQwerty123.Gettext
  alias NotQwerty123.WordlistManager

  @doc """
  Check the strength of the password.

  It returns {:ok, password} or {:error, message}

  The password is checked to make sure that it is not too short and
  that it is not similar to any word in the common password list.
  See the documentation for NotQwerty123.WordlistManager for
  information about customizing the common password list.

  ## Options

  There is one option:

    * min_length - minimum allowable length of the password
      * default is 8

  """
  def strong_password?(password, opts \\ []) do
    min_len = Keyword.get(opts, :min_length, 8)
    case long_enough?(String.length(password), min_len) do
      true ->
        if easy_guess?(password) do
          {:error, gettext("The password you have chosen is weak because it is easy to guess. " <>
                             "Please choose another one.")}
        else
          {:ok, password}
        end
      message -> {:error, message}
    end
  end

  defp long_enough?(word_len, min_len) when word_len < min_len do
    gettext "The password should be at least %{min_len} characters long.", min_len: min_len
  end
  defp long_enough?(_, _), do: true

  defp easy_guess?(password) do
    key = String.downcase(password)
    Regex.match?(~r/^.?(..?.?.?.?.?.?.?)(\1+).?$/, key) or
    WordlistManager.query(key)
  end
end
