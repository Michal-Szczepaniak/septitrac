Name:       Septitrac
Summary:    Septitrac
Version:    1.2.2
Release:    1
Group:      Qt/Qt
License:    GPLv3
URL:        http://example.org/
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   qt5-qtdeclarative-import-location
Requires:   qt5-qtdeclarative-import-positioning
Requires:   mapboxgl-qml
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Traccar client.

%prep
%setup -q -n %{name}-%{version}

%build
CXXFLAGS="${CXXFLAGS} -O3"
export CXXFLAGS
%qmake5

make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
