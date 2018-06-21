pkg_name=hab-static-website
pkg_origin=cnunciato
pkg_version="0.1.0"
pkg_maintainer="Christian Nunciato <chris@nunciato.org>"

do_install() {
  return 0
}

do_build() {
  local docroot="$pkg_prefix/www"

  mkdir -p $docroot
  cp index.html $docroot/
}
