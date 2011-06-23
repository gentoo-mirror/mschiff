# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit java-pkg-2

DESCRIPTION="Offers two-way synchronization between Google Calendar and other iCal compatible calendar apps"
HOMEPAGE="http://gcaldaemon.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-linux-${PV/_/-}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND=">=virtual/jre-1.5"
DEPEND="${RDEPEND}"

src_compile() {
	return 0
}

src_install() {
	cd GCALDaemon
	java-pkg_dojar lib/*.jar
	if use doc; then
		dohtml -r docs/*
	fi
	exeinto /usr/bin
	doexe "${FILESDIR}/gcaldaemon"
}
