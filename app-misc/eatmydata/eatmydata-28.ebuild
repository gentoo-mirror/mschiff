# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="Tool with LD_PRELOAD library that disables all forms of writing data safely to disk"
HOMEPAGE="https://launchpad.net/libeatmydata"
SRC_URI="http://launchpad.net/lib${PN}/trunk/release-${PV}/+download/lib${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

MY_S="${WORKDIR}/lib${P}"
S="${WORKDIR}/lib${P}"

src_install () {
	default
	exeinto /usr/bin && doexe ${FILESDIR}/eatmydata
	doman ${FILESDIR}/eatmydata.1.gz
	find ${D} -name "*.la" -delete
}

pkg_postinst() {
	ewarn "This program is called *eatmydata* on purpose."
	ewarn "Use it on your own risk and only if you know what you are doing."
}
