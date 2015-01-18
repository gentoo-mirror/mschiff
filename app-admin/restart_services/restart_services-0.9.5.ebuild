# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Utility to manage OpenRC services that need to be restarted"
HOMEPAGE="http://dev.gentoo.org/~mschiff/src/restart_services"
SRC_URI="http://dev.gentoo.org/~mschiff/src/${PN}/${P}.tgz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-admin/lib_users"
RDEPEND="${DEPEND}"

src_install() {
	exeinto /usr/sbin
	doexe restart_services
	doman restart_services.1
	insinto /etc
	doins restart_services.conf
	dodoc README CHANGES
}
