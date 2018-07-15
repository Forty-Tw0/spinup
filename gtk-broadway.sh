# https://stefanoprenna.com/blog/2016/02/06/tutorial-stream-gtk-applications-and-use-them-in-your-browser-with-gtk-and-broadway/
yum install -y gcc-c++ make ninja-build
yum install -y http://dl.fedoraproject.org/pub/epel/testing/7/x86_64/Packages/m/meson-0.47.1-1.el7.noarch.rpm
yum install -y libffi-devel zlib-devel libmount-devel libselinux-devel cairo-devel cairo-gobject-devel

cd /tmp
wget https://github.com/fribidi/fribidi/archive/v1.0.4.tar.gz
tar vzxf v1.0.4.tar.gz
cd fribidi-1.0.4
#install at /usr instead of /something/local
meson -Dprefix=/usr -Ddocs=false _build .
cd _build
ninja-build
ninja-build install

cd /tmp
#2.13 requires a newer freetype2 that I don't care to install
wget https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.11.95.tar.gz
tar vzxf fontconfig-*
cd fontconfig-*
./configure --sysconfdir=/etc --prefix=/usr --libdir=/usr/lib64 --mandir=/usr/share/man
make
make install

cd /tmp
wget http://ftp.gnome.org/pub/gnome/sources/gtk+/3.94/gtk+-3.94.0.tar.xz
tar xvfJ gtk+-*.tar.xz
cd gtk+-*
sed -i 's/https:\/\/git.gnome.org\/browse\/pango/https:\/\/gitlab.gnome.org\/GNOME\/pango.git/g' subprojects/pango.wrap
sed -i 's/ssh:\/\/git.gnome.org\/git\/pango/ssh:\/\/git@gitlab.gnome.org:GNOME\/pango.git/g' subprojects/pango.wrap
#might need to remove fontconfig? Not sure how it got installed.
meson -D broadway-backend=true _build .
