# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Wuala, your free online hard-disk"
HOMEPAGE="http://wuala.com/"
SRC_URI="http://www.wuala.com/files/wuala.tar.gz"

LICENSE="wuala"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="sys-fs/fuse
	>=virtual/jre-1.5.0
	x11-misc/xdg-utils"

S="${WORKDIR}/${PN}"

src_prepare() {
	MY_S="$PN"
	cd ${PN}
	sed -i wuala -e 's|loader3\.jar|/opt/wuala/loader3.jar|'
}

src_install() {
	cd ${PN}
	dodir /opt/${PN}

	insinto /opt/${PN}
	doins loader3.jar

	exeinto /opt/${PN}
	doexe wuala wualacmd
	dosym /opt/${PN}/wuala /opt/bin/wuala
	dosym /opt/${PN}/wualacmd /opt/bin/wualacmd

	dodoc readme.txt
}