# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_WARN_UNUSED_CLI=no
CMAKE_REMOVE_MODULES=yes

inherit cmake-utils eutils webapp git-r3

MY_PV=${PV/_/-}
MY_PN="bareos"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Featureful client/server network backup suite"
HOMEPAGE="https://www.bareos.org/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/${MY_PN}/${MY_PN}.git"
RESTRICT="mirror"

LICENSE="AGPL-3"

KEYWORDS="~amd64 ~x86"
IUSE="mysql +postgres"

DEPEND=""
RDEPEND="${DEPEND}
	dev-lang/php[mysql?,pdo,postgres?]
	virtual/httpd-php
"

need_httpd_cgi

S=${WORKDIR}/${PF}/webui

pkg_setup() {
	webapp_pkg_setup
}

src_configure() {
	pushd ${WORKDIR}/${PF}
	CURRENT_VERSION=$(echo $(cmake -P get_version.cmake) | sed 's/[- ]//g')
	popd
	local mycmakeargs=(
		-DVERSION_STRING=${CURRENT_VERSION}
	)

	cmake-utils_src_configure
}

src_install() {
	webapp_src_preinst

	dodoc LICENSE README.md
	webapp_server_configfile nginx ${S}/install/nginx/bareos-webui.conf bareos-webui.include
	webapp_server_configfile apache ${S}/install/apache/bareos-webui.conf bareos-webui.conf
#	webapp_postinst_txt en "${FILESDIR}"/postinstall-en.txt

	insinto "${MY_HTDOCSDIR#${EPREFIX}}"
	pushd "${BUILD_DIR}" > /dev/null || die
	DESTDIR="${D}/${MY_HTDOCSDIR#${EPREFIX}}" ${CMAKE_MAKEFILE_GENERATOR} install "$@" || die "died running ${CMAKE_MAKEFILE_GENERATOR} install"
	popd > /dev/null || die

	webapp_configfile "${MY_HTDOCSDIR#${EPREFIX}}"/bareos-webui/config/application.config.php
	webapp_configfile "${MY_HTDOCSDIR#${EPREFIX}}"/bareos-webui/config/autoload/global.php

	mv "${D}/${MY_HTDOCSDIR#${EPREFIX}}"/bareos-webui/* "${D}/${MY_HTDOCSDIR#${EPREFIX}}"/
	rmdir "${D}/${MY_HTDOCSDIR#${EPREFIX}}"/bareos-webui
	find "${D}/${MY_HTDOCSDIR#${EPREFIX}}" -type f -name '*.in' -delete

	mv "${D}/${MY_HTDOCSDIR#${EPREFIX}}/etc" "${D}/etc"
	rm -rf "${D}/etc/httpd"

	webapp_src_install
}
