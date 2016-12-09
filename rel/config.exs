use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"$f7NWH}G4.(n7wL`Mb!895x}4ZQsV|Kq[j~mYHQm17sviL7d78c:cjq<3,`AA=K1"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"*rw}s|M@6Zjo`N])O/?7duCZjc=jo<nDDLN8vj?A>(9Ngv>v|<v2K=UIZ;d`T0,Z"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :impact do
  set version: current_version(:impact)
end

