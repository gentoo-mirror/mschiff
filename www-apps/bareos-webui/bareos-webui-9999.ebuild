# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_WARN_UNUSED_CLI=no
CMAKE_MAKEFILE_GENERATOR="emake"

MY_PV=${PV/_/-}
MY_PN="bareos"
MY_P="${MY_PN}-${MY_PV}"

if [[ ${PV} == 9999 ]]; then
	inherit cmake webapp git-r3
	S=${WORKDIR}/${PF}/webui
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/${MY_PN}/${MY_PN}.git"
	KEYWORDS=""
else
	inherit cmake webapp
	S=${WORKDIR}/${MY_PN}-Release-${PV}/webui
	SRC_URI="https://github.com/${MY_PN}/${MY_PN}/archive/Release/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Featureful client/server network backup suite"
HOMEPAGE="https://www.bareos.org/"
RESTRICT="mirror"

LICENSE="AGPL-3"

IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	dev-lang/php[bzip2,ctype,curl,fileinfo,filter,fpm,gd,iconv,intl,mhash,nls,pdo,postgres,session,simplexml,ssl,xml,xmlreader,xmlwriter,zip]
	virtual/httpd-php
"

need_httpd_fastcgi

pkg_setup() {
	webapp_pkg_setup
}

src_prepare() {
	# fix missing VERSION
	sed -i "s/@BAREOS_FULL_VERSION@/${PV}/g" version.php.in || die

	cmake_src_prepare
	default
}

src_configure() {
	if [[ ${PV} == 9999 ]]; then
		pushd "${WORKDIR}/${PF}"
	else
		pushd "${S}"/..
	fi
	CURRENT_VERSION=$(echo $(cmake -P get_version.cmake) | sed 's/[- ]//g')
	popd
	local mycmakeargs=(
		-DVERSION_STRING=${CURRENT_VERSION}
		-Wno-dev
	)
	cmake_src_configure
}

src_install() {
	webapp_src_preinst

	dodoc README.md doc/README-TRANSLATION.md

	dodir "/etc/bareos/bareos-dir.d"
	cp -r install/bareos/bareos-dir.d/* "${D}/etc/bareos/bareos-dir.d"

	sed -i -e "s,/var/www/bareos-webui/,${MY_HTDOCSDIR}," "install/nginx/bareos-webui.conf"
	sed -i -e "s,/usr/share/bareos-webui/,${MY_HTDOCSDIR}," "install/apache/bareos-webui.conf"

	webapp_server_configfile nginx "install/nginx/bareos-webui.conf" bareos-webui.include
	webapp_server_configfile apache "install/apache/bareos-webui.conf" bareos-webui.conf

	insinto /etc/${PN}
	doins install/{configuration,directors}.ini

	insinto "${MY_HTDOCSDIR#${EPREFIX}}"
	doins -r .

	webapp_configfile "${MY_HTDOCSDIR#${EPREFIX}}"/config/application.config.php
	webapp_configfile "${MY_HTDOCSDIR#${EPREFIX}}"/config/autoload/global.php

	keepdir "${MY_HTDOCSDIR#${EPREFIX}}"/data
	webapp_serverowned "${MY_HTDOCSDIR#${EPREFIX}}"/data

	# cleanup
	find  "${D}/${MY_HTDOCSDIR#${EPREFIX}}" -name "*.in" -delete
	rm -rf "${D}/${MY_HTDOCSDIR#${EPREFIX}}"/{CMakeLists.txt,install,cmake,phpunit.xml,scripts,doc,tests}

	webapp_postinst_txt en ${FILESDIR}/postinstall-en.txt

	webapp_src_install
}

pkg_postinst() {
	einfo ""
	einfo "The webui uses 'webapp-config' to be configured. To install it may be called like so:"
	einfo ""
	einfo "  webapp-config -h localhost -d bareos-webui -I bareos-webui ${PV}"
	einfo ""
	einfo "See 'man webapp-config' for more details."
	einfo ""
	einfo "For more details about how to configure the bareos webui, see:"
	einfo "  https://docs.bareos.org/IntroductionAndTutorial/InstallingBareosWebui.html"
	einfo ""
	ewarn ""
	ewarn "You need to configure your webserver!"
	ewarn "vhost configuration templates can be found under /usr/share/webapps/bareos-webui/${PV}/conf"
	ewarn ""
	ewarn "IMPORTANT: make sure the docroot of your webserver points to the public/ folder within webapp htdocs directory"
	ewarn ""
}
