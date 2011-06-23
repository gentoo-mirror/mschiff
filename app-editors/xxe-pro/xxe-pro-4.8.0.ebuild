# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

MY_PV="${PV//./_}"
MY_PV="${MY_PV/_p/p}"
S="${WORKDIR}/${PN}-${MY_PV}"

DESCRIPTION="The XMLmind XML Editor (Professional Version)"
HOMEPAGE="http://www.xmlmind.com/xmleditor/index.html"
SRC_URI="http://www.xmlmind.com/store_download/xe-usr-4.8/${PN}-${MY_PV}.tar.gz"
IUSE=""

SLOT="0"
LICENSE="as-is"
KEYWORDS="~amd64 ~x86"

RESTRICT="fetch strip mirror"
RDEPEND=">=virtual/jre-1.5.0"
DEPEND=""
INSTALLDIR=/opt/${PN}

src_install() {
	dodir ${INSTALLDIR}
	cp -pPR "${S}"/* "${D}"/${INSTALLDIR}

	dodir /etc/env.d
	echo -e "PATH=${INSTALLDIR}/bin\nROOTPATH=${INSTALLDIR}" > "${D}"/etc/env.d/10xxe-pro

	insinto /usr/share/applications
	doins "${FILESDIR}"/xxe-pro.desktop
}

pkg_postinst() {
	einfo
	einfo "XXE Pro has been installed in /opt/${PN}, to include this"
	einfo "in your path, run the following:"
	einfo "    /usr/sbin/env-update && source /etc/profile"
	einfo
}
