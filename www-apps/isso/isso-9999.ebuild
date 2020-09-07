# By eroen, 2014
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# $Header: $

EAPI=5
# setup.py disallows 30 31 32
# setup.py documents support 26	 27  33
# dev-python/html5lib					-34
# dev-python/itsdangerous				-34
# dev-python/misaka			-26		-33	-34
# dev-python/werkzeug					-34
# dev-python/configparser	-26
# dev-python/ipaddr			-26
PYTHON_COMPAT=( python3_{7,8} )

if [[ $PV == *9999* ]]; then
	inherit user distutils-r1 git-r3
	EGIT_REPO_URI=https://github.com/posativ/${PN}.git
	JS_REPO_URIS=( https://github.com/jrburke/almond.git
		https://github.com/jrburke/r.js.git
		https://github.com/requirejs/text.git )
	VCS_DEPEND="dev-vcs/git[curl]"
else
	inherit user distutils-r1
	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
fi

DESCRIPTION="lightweight Disqus alternative"
HOMEPAGE="http://posativ.org/isso/ https://pypi.python.org/pypi/isso/ https://github.com/posativ/isso/"
# BSD: pbkdf2.js sha1.js crypto.py?
LICENSE="MIT BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
if [[ ${PV} == *9999* ]]; then
	IUSE+=" debug doc test"
	DOCS=( README.md CHANGES.rst docs/{contribute.rst,faq.rst} )
else
	DOCS=( )
fi

LIBDEPEND="dev-python/html5lib[${PYTHON_USEDEP}]
	dev-python/itsdangerous[${PYTHON_USEDEP}]
	>=dev-python/misaka-2.0[${PYTHON_USEDEP}]
	<dev-python/misaka-3.0[${PYTHON_USEDEP}]
	dev-python/ipaddr[${PYTHON_USEDEP}]
	dev-python/bleach[${PYTHON_USEDEP}]
	"
HDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
if [[ ${PV} == *9999* ]]; then
	HDEPEND+=" ${VCS_DEPEND}
		dev-ruby/sass
		net-libs/nodejs
		doc? ( dev-python/sphinx )"
fi
DEPEND="${HDEPEND}"
if [[ ${PV} == *9999* ]]; then
	DEPEND+=" test? ( dev-python/nose[${PYTHON_USEDEP}]
		${LIBDEPEND} )"
fi
RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	${LIBDEPEND}"

pkg_setup() {
	enewuser ${PN}
}

src_fetch() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_fetch
		for EGIT_REPO_URI in "${JS_REPO_URIS[@]}"; do (
			unset ${PN}_LIVE_REPO
			git-r3_src_fetch
		); done
	else
		default
	fi
}

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
		for EGIT_REPO_URI in "${JS_REPO_URIS[@]}"; do (
			unset ${PN}_LIVE_REPO;
			EGIT_CHECKOUT_DIR=${WORKDIR}/${EGIT_REPO_URI##*/} git-r3_src_unpack
		); done
		mkdir -p "${S}"/isso/js/components/{requirejs-text,almond} || die
		cp "${WORKDIR}"/text.git/text.js "${S}"/isso/js/components/requirejs-text/ || die
		cp "${WORKDIR}"/almond.git/almond.js "${S}"/isso/js/components/almond/ || die
	else
		default
	fi
}

src_compile() {
	if [[ ${PV} == *9999* ]]; then
		# build r.js
		pushd "${WORKDIR}"/r.js.git 2>/dev/null
		node dist.js || die
		popd 2>/dev/null
		local RJS=${WORKDIR}/r.js.git/r.js

		# generate css
		scss isso/css/isso.scss isso/css/isso.css || die

		# generate js using r.js
		node "${RJS}" -o isso/js/build.embed.js || die
		node "${RJS}" -o isso/js/build.count.js || die
		if use debug; then
			node "${RJS}" -o isso/js/build.embed.js optimize="none" out="isso/js/embed.dev.js" || die
			node "${RJS}" -o isso/js/build.count.js optimize="none" out="isso/js/count.dev.js" || die
		fi
	fi
	distutils-r1_src_compile
}

python_compile_all() {
	if [[ ${PV} == *9999* ]]; then
		if use doc; then
			mkdir -p "${T}"/html || die
			pushd docs 2>/dev/null || die
			sphinx-build -E -b dirhtml -a . "${T}"/html || die
			popd 2>/dev/null || die
			mkdir -p "${T}"/html/_static/css || die
			scss docs/_static/css/site.scss "${T}"/html/_static/css/site.css || die
		fi
	fi
}

python_test() {
	if [[ ${PV} == *9999* ]]; then
		# doctests fail, require https://github.com/gnublade/doctest-ignore-unicode
		nosetests \
			--with-coverage --cover-package=isso \
			isso/ specs/ \
			|| die "tests failed"
		#nosetests --with-doctest --with-doctest-ignore-unicode \
		#	--with-coverage --cover-package=isso \
		#	isso/ specs/ \
		#	|| die "tests failed"
	fi
}

python_install_all() {
	distutils-r1_python_install_all

	insinto /etc
	doins share/${PN}.conf
	if [[ ${PV} == *9999* ]]; then
		use doc && dodoc -r "${T}"/html
	fi

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
}
