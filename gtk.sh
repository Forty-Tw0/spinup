yum install -y epel-release
yum install -y git wget gcc-c++ make python34 bison flex ninja-build
yum install -y http://dl.fedoraproject.org/pub/epel/testing/7/x86_64/Packages/m/meson-0.47.1-1.el7.noarch.rpm
yum install -y gettext libffi-devel zlib-devel libmount-devel libselinux-devel cairo-devel cairo-gobject-devel gobject-introspection-devel atk-devel cups-devel

cd /tmp
wget https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz
tar xzf freetype*.tar.gz
cd freetype*
./configure --sysconfdir=/etc --prefix=/usr --libdir=/usr/lib64 --mandir=/usr/share/man
make
make install

cd /tmp
wget https://github.com/fribidi/fribidi/archive/v1.0.4.tar.gz
tar xzf v1.0.4.tar.gz
cd fribidi-*
meson -Dprefix=/usr -Ddocs=false _build .
cd _build
ninja-build
ninja-build install

cd /tmp
#2.13 requires a newer freetype2 that I don't care to install
wget https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.11.95.tar.gz
tar xzf fontconfig-*.tar.gz
cd fontconfig-*
./configure --sysconfdir=/etc --prefix=/usr --libdir=/usr/lib64 --mandir=/usr/share/man
make
make install

cd /tmp
wget https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-1.4.2.tar.bz2
yum install -y bzip2
tar xjf harfbuzz-*.tar.bz2
cd harfbuzz-*
./configure --sysconfdir=/etc --prefix=/usr --libdir=/usr/lib64 --mandir=/usr/share/man
make
make install

cd /tmp
wget https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.14.1.tar.xz
tar xfJ gstreamer-*.tar.xz
cd gstreamer-*
./configure --sysconfdir=/etc --prefix=/usr --libdir=/usr/lib64 --mandir=/usr/share/man
make
make install

cd /tmp
wget https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.14.1.tar.xz
tar xfJ gst-plugins-base-*.tar.xz
cd gst-plugins-base-*
./configure --sysconfdir=/etc --prefix=/usr --libdir=/usr/lib64 --mandir=/usr/share/man
make
make install

cd /tmp
wget https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.14.1.tar.xz
tar xfJ gst-plugins-bad-*.tar.xz
cd gst-plugins-bad-*
./configure --sysconfdir=/etc --prefix=/usr --libdir=/usr/lib64 --mandir=/usr/share/man
make
make install

cd /tmp
wget https://download.gnome.org/sources/pango/1.42/pango-1.42.1.tar.xz
tar xfJ pango-*.tar.xz
cd pango-*
./configure --sysconfdir=/etc --prefix=/usr --libdir=/usr/lib64 --mandir=/usr/share/man
make
make install

cd /tmp
wget https://download.gnome.org/sources/gdk-pixbuf/2.37/gdk-pixbuf-2.37.0.tar.xz
tar xfJ gdk-pixbuf-*.tar.xz
cd gdk-pixbuf-*
meson --prefix=/usr -Dman=false _build .
cd _build
ninja-build
ninja-build install

cd /tmp
git clone https://gitlab.gnome.org/GNOME/gtk.git
cd gtk
#######
sed -i 's/https:\/\/git.gnome.org\/browse\/pango/https:\/\/gitlab.gnome.org\/GNOME\/pango.git/g' subprojects/pango.wrap
sed -i 's/ssh:\/\/git.gnome.org\/git\/pango/ssh:\/\/git@gitlab.gnome.org:GNOME\/pango.git/g' subprojects/pango.wrap
sed -i 's/https:\/\/git.gnome.org\/browse\/gdk-pixbuf/https:\/\/gitlab.gnome.org\/GNOME\/gdk-pixbuf.git/g' subprojects/gdk-pixbuf.wrap
sed -i 's/ssh:\/\/git.gnome.org\/git\/gdk-pixbuf/ssh:\/\/git@gitlab.gnome.org:GNOME\/gdk-pixbuff.git/g' subprojects/gdk-pixbuf.wrap
sed -i 's/^graphene_has_sse2 = .*$/graphene_has_sse2 = true/g' meson.build
sed -i 's/^graphene_has_gcc = .*$/graphene_has_gcc = true/g' meson.build
#######
meson --prefix=/usr -Dbroadway-backend=true -Dx11-backend=false -Dwayland-backend=false _build .
cd _build
ninja-build
ninja-build install

cd /tmp
wget https://icon-theme.freedesktop.org/releases/hicolor-icon-theme-0.17.tar.xz
tar xfJ hicolor-icon-theme-*tar.xz
cd /hicolor-icon-theme-*
make clean
./autogen.sh
make install

gtk4-broadwayd -a $(hostname -s) &
GDK_BACKEND=broadway BROADWAY_DISPLAY=:0 /tmp/gtk/_build/demos/gtk-demo/gtk4-demo
