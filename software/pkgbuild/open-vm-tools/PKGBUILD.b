# Maintainer: Sergej Pupykin <pupykin.s+arch@gmail.com>
# Contributor: Krzysztof Raczkowski <raczkow@gmail.com>

pkgname=open-vm-tools
epoch=6
pkgver=12.2.0
pkgrel=1
pkgdesc='The Open Virtual Machine Tools (open-vm-tools) are the open source implementation of VMware Tools'
#arch=('x86_64')
arch=('aarch64')
url='https://github.com/vmware/open-vm-tools'
license=('LGPL')
depends=('fuse3' 'icu' 'iproute2' 'libdnet' 'libmspack' 'libsigc++'
         'libxcrypt' 'libcrypt.so' 'libxss' 'lsb-release' 'procps-ng'
         'uriparser' 'gdk-pixbuf-xlib')
makedepends=('chrpath' 'doxygen' 'gtkmm3' 'libxtst' 'python' 'rpcsvc-proto')
checkdepends=('cunit')
optdepends=('gtkmm3: DnD/CP plugin'
            'libxtst: DnD/CP, resolution set plugins'
            'netctl: suspend-resume network state'
            'networkmanager: suspend-resume network state')
backup=('etc/xdg/autostart/vmware-user.desktop')
options=('docs')
source=("$pkgname-$pkgver.tar.gz::https://github.com/vmware/open-vm-tools/archive/stable-${pkgver/_/-}.tar.gz"
        'vmtoolsd.service'
        'vmware-vmblock-fuse.service')
sha256sums=('5127dd8643e4c89a22a93728ea5420d236cd4083bc07d665f70fee08a581d635'
            '0626cc86232f75a7286c24c52d6b44260bba55e2e96c17fa22ed36decb61a4d9'
            '99e3cc1da20a751049144cc02dec77174a55109b5b5960e1facd78709da7724f')

prepare() {
  cd "$srcdir/$pkgname-stable-${pkgver}/open-vm-tools/"

  autoreconf -vi
}

build() {
  cd "$srcdir/$pkgname-stable-${pkgver}/open-vm-tools/"

  sh ./configure \
    --prefix=/usr \
    --sbindir=/usr/bin \
    --sysconfdir=/etc \
    --with-udev-rules-dir=/usr/lib/udev/rules.d \
    --without-xmlsecurity \
    --without-kernel-modules
  make
}

check() {
  cd "$srcdir/$pkgname-stable-${pkgver}/open-vm-tools/"

  make check
}

package() {
  cd "$srcdir/$pkgname-stable-${pkgver}/open-vm-tools/"

  make install DESTDIR="$pkgdir"
  chmod 7755 "$pkgdir"/usr/bin/vmware-user-suid-wrapper

  # install vmware-xdg-detect-de
  install -D -m0755 scripts/common/vmware-xdg-detect-de "$pkgdir"/usr/bin/vmware-xdg-detect-de

  # install systemd files
  install -D -m0644 "$srcdir"/vmtoolsd.service "$pkgdir"/usr/lib/systemd/system/vmtoolsd.service
  install -D -m0644 "$srcdir"/vmware-vmblock-fuse.service "$pkgdir"/usr/lib/systemd/system/vmware-vmblock-fuse.service
}
