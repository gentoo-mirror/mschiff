# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils qt4-r2 toolchain-funcs

if [[ ${PV} == "9999" ]] ; then
	ESVN_REPO_URI="http://i7z.googlecode.com/svn/trunk/"
	inherit subversion autotools
else
	SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="A better i7 (and now i3, i5) reporting tool for Linux"
HOMEPAGE="http://code.google.com/p/i7z/"

SLOT="0"
KEYWORDS=""
LICENSE="GPL-2"
IUSE="X"

RDEPEND="
	sys-libs/ncurses
	X? ( x11-libs/qt-gui:4 )"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/0.26-gentoo.patch
	tc-export CC
}

src_compile() {
	emake || die
	if use X; then
		cd GUI
		eqmake4 GUI.pro
		emake || die
	fi
}

src_install() {
	emake DESTDIR="${ED}" install
	if use X; then
		newsbin GUI/GUI i7z_GUI
	fi
	dodoc put_cores_o*line.sh MAKEDEV-cpuid-msr
}
