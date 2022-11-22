# Pleroma instance configuration

# NOTE: This file should not be committed to a repo or otherwise made public
# without removing sensitive information.

import Config

config :pleroma, Pleroma.Web.Endpoint,
   url: [host: "dabr.ca", scheme: "https", port: 443],
   http: [ip: {0, 0, 0, 0}, port: 4000],

config :pleroma, :instance,
  name: "dabr.ca",
  email: "wzyboy@wzyboy.org",
  notify_email: "no-reply@dabr.ca",
  limit: 5000,
  registrations_open: true

config :pleroma, :media_proxy,
  enabled: false,
  redirect_on_failure: true
  #base_url: "https://cache.pleroma.social"

config :pleroma, Pleroma.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER", "pleroma"),
  password: System.fetch_env!("DB_PASS"),
  database: System.get_env("DB_NAME", "pleroma"),
  hostname: System.get_env("DB_HOST", "localhost"),

# Configure web push notifications
config :web_push_encryption, :vapid_details, subject: "mailto:wzyboy@wzyboy.org",

config :pleroma, :database, rum_enabled: false
config :pleroma, :instance, static_dir: "/var/lib/pleroma/static"
config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"

# Enable Strict-Transport-Security once SSL is working:
# config :pleroma, :http_security,
#   sts: true

# Configure S3 support if desired.
# The public S3 endpoint (base_url) is different depending on region and provider,
# consult your S3 provider's documentation for details on what to use.
#
# config :pleroma, Pleroma.Upload,
#  uploader: Pleroma.Uploaders.S3,
#  base_url: "https://s3.amazonaws.com"
#
# config :pleroma, Pleroma.Uploaders.S3,
#   bucket: "some-bucket",
#   bucket_namespace: "my-namespace",
#   truncated_namespace: nil,
#   streaming_enabled: true
#
# Configure S3 credentials:
# config :ex_aws, :s3,
#   access_key_id: "xxxxxxxxxxxxx",
#   secret_access_key: "yyyyyyyyyyyy",
#   region: "us-east-1",
#   scheme: "https://"
#
# For using third-party S3 clones like wasabi, also do:
# config :ex_aws, :s3,
#   host: "s3.wasabisys.com"

config :pleroma, Pleroma.Upload, filters: [Pleroma.Upload.Filter.Exiftool]

# Generate and include secrets
# https://github.com/angristan/docker-pleroma/blob/51724af0882b908a18dc12c11fef60eb8308fb3a/config.exs#L37-L62
if not File.exists?("/var/lib/pleroma/secret.exs") do
  secret = :crypto.strong_rand_bytes(64) |> Base.encode64() |> binary_part(0, 64)
  signing_salt = :crypto.strong_rand_bytes(8) |> Base.encode64() |> binary_part(0, 8)
  {web_push_public_key, web_push_private_key} = :crypto.generate_key(:ecdh, :prime256v1)

  secret_file =
    EEx.eval_string(
      """
      import Config
      config :pleroma, Pleroma.Web.Endpoint,
        secret_key_base: "<%= secret %>",
        signing_salt: "<%= signing_salt %>"
      config :web_push_encryption, :vapid_details,
        public_key: "<%= web_push_public_key %>",
        private_key: "<%= web_push_private_key %>"
      """,
      secret: secret,
      signing_salt: signing_salt,
      web_push_public_key: Base.url_encode64(web_push_public_key, padding: false),
      web_push_private_key: Base.url_encode64(web_push_private_key, padding: false)
    )

  File.write("/var/lib/pleroma/secret.exs", secret_file)
end

import_config("/var/lib/pleroma/secret.exs")
