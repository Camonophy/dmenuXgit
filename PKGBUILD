# Maintainer: Oliver Pflug <pflug-oliver@gmx.de>
pkgname='dmenuxgit'
pkgver=0.1
pkgrel=1
pkgdesc="Use dmenu to navigate through various Git commands"
arch=('x86_64')
url="https://github.com/Camonophy/dmenuXgit"
license=('BSD-3-Clause License')
depends=('dmenu' 'git')
source=('https://github.com/Camonophy/dmenuXgit')
md5sums=('SKIP')

package() {
	mkdir -p "${pkgdir}/usr/bin" "${pkgdir}/usr/share/dmenuxgit"
	install -Dm755 "${srcdir}/dmenuxgit" "${pkgdir}/usr/bin"
	chmod 755 "${srcdir}/dxgscript.sh"
	mv "${srcdir}/dxgscript.sh" "${pkgdir}/usr/share/dmenuxgit"
	touch dmenuxgit.conf
	install -Dm666 "dmenuxgit.conf" "${pkgdir}/usr/share/dmenuxgit"
	touch untracked_files.txt
	chmod 666 untracked_files.txt
	mv untracked_files.txt "${pkgdir}/usr/share/dmenuxgit"
}