# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils subversion systemd

DESCRIPTION="A tool to configure unbound with usable DNSSEC servers."
HOMEPAGE="http://www.nlnetlabs.nl/projects/dnssec-trigger/"
ESVN_REPO_URI="http://www.nlnetlabs.nl/svn/${PN}/trunk"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="openrc +networkmanager"

COMMON_DEPEND="
	net-libs/ldns
	media-libs/harfbuzz
"
DEPEND="
	${COMMON_DEPEND}
	openrc? ( dev-util/systemd2openrc )
"
RDEPEND="
	${COMMON_DEPEND}
	net-dns/unbound
"

src_prepare() {
	default

	epatch_user

	# Move around files to the right places
	if [ -e contrib/dnssec-triggerd.service -a -e contrib/dnssec-trigger-script ]; then
		:
	else
		cp dnssec-triggerd{,-keygen}.service contrib/ || die
		sed -i '/ExecStopPost/a ExecStopPost=rm -f /var/run/dnssec-trigger/*' contrib/dnssec-triggerd.service || die
		sed -i 's|ExecStart=/sbin/restorecon |ExecStart=-/sbin/restorecon |' contrib/dnssec-triggerd-keygen.service || die
		sed -i 's|/usr/sbin/pidof|/bin/pidof|' dnssec-trigger-script.in || die
	fi
}

src_configure() {
	econf --with-keydir=/etc/dnssec-trigger
}

src_compile() {
	default

	if use openrc; then
		mkdir openrc || die
		systemd2openrc contrib/dnssec-triggerd.service > openrc/dnssec-triggerd || die
		systemd2openrc contrib/dnssec-triggerd-keygen.service > openrc/dnssec-triggerd-keygen || die
	fi
}

src_install() {
	default

	#dodir /var/run/dnssec-trigger
	#keepdir /var/run/dnssec-trigger || die

	# Install systemd units
	for i in contrib/*.service ; do
		systemd_dounit $i || die
	done

	# Instal OpenRC initscripts
	if [ -d openrc ]; then
		for i in openrc/*; do
			doinitd $i || die
		done
	fi

	if use networkmanager; then
		# Install the helper script
		exeinto /usr/libexec
		doexe dnssec-trigger-script
	else
		rm -rf "${ED}/etc/NetworkManager"
	fi
}
