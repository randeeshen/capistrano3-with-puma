# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Capistrano3WithPuma::Application.config.secret_key_base = 'e574a52bd422a7e4f363599b4a5ad3b3145544fb0b0f7dae648be10dba85035cab21bb82e6ab36675e2ad39a65d84e5988f7b002cf65056ecc826982f9377110'
